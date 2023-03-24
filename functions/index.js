const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const stripe = require("stripe")("sk_test_51LNoueEnfC2xSvf19eTNGHtbE8EignxzaPdYScS4sCqEKak0U4QGHgQGONc6JR369onhzBTOMb23KKS4OxD9gSkZ00vvJc7InF");

// When a user is created, register them with Stripe
exports.createStripeCustomer = functions.auth.user().onCreate((user) => {
  return stripe.customers.create({
    email: user.email,
  }).then((customer) => {
    return admin.firestore().collection("stripe_customers").doc(String(user.uid)).set({customerID: customer.id});
  });
});

exports.createCharge = functions.https.onCall((data, context) => {
  const customerID = data.customerID;
  const totalAmount = data.total;
  const paymentStripeID = data.paymentStripeID;
  const idempotency = data.idempotency;
  const uid = context.auth.uid;
  if (uid === null) {
    console.log("Illegal access attempt due to unauthenticated user.");
    throw new functions.https.HttpsError("permission-denied", "Illegal access attempt.");
  }
  return stripe.paymentIntents.create({
    amount: totalAmount,
    currency: "usd",
    customer: customerID,
    payment_method: paymentStripeID,
  }, {
    idempotency_key: idempotency,
  }).then((paymentIntent) => {
    return stripe.paymentIntents.confirm(paymentIntent.id,
      {payment_method: paymentStripeID});
  }).catch((err) => {
    console.log(err);
    throw new functions.https.HttpsError("internal", "Unable to create charge.");
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
