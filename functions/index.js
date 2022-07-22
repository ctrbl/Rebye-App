const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const stripe = require("stripe")("sk_test_51LNoueEnfC2xSvf19eTNGHtbE8EignxzaPdYScS4sCqEKak0U4QGHgQGONc6JR369onhzBTOMb23KKS4OxD9gSkZ00vvJc7InF");

app.post('/payment-sheet', async (req, res) => {
  // Use an existing Customer ID if this is a returning customer.
  const customer = await stripe.customers.create();
  const ephemeralKey = await stripe.ephemeralKeys.create(
    {customer: customer.id},
    {apiVersion: '2020-08-27'}
  );
  const paymentIntent = await stripe.paymentIntents.create({
    amount: 1099,
    currency: 'eur',
    customer: customer.id,
    automatic_payment_methods: {
      enabled: true,
    },
  });

  res.json({
    paymentIntent: paymentIntent.client_secret,
    ephemeralKey: ephemeralKey.secret,
    customer: customer.id,
    publishableKey: 'pk_test_51LNoueEnfC2xSvf1BMYMcfoMUZGeC5IyWa3HkPxWRELnCVhLaTsT2P8IEAnCPkEFVy8WdvgsE2aht9dn8Hec5vPa00sq1X5239'
  });
});

// When a user is created, register them with Stripe
exports.createStripeCustomer = functions.auth.user().onCreate((user) => {
  return stripe.customers.create({
    email: user.email,
  }).then((customer) => {
    return admin.firestore().collection("stripe_customers").doc(String(user.uid)).set({customerID: customer.id});
  });
});

exports.createEphemeralKey = functions.https.onCall((data, context) => {
  const customerID = data.customerID;
  const stripeVersion = data.stripe_version;
  const uid = context.auth.uid;

  if (uid === null) {
    console.log("Illegal access attempt due to unauthenticated user");
    throw new functions.https.HttpsError("permission-denied", "Illegal access attempt.");
  }

  return stripe.ephemeralKeys.create(
    {customer: customerID},
    {stripe_version: stripeVersion}
  ).then((key) => {
    return key;
  }).catch((err) => {
    console.log(err);
    throw new functions.https.HttpsError("internal", "Unable to create ephemeral key.");
  });
});
