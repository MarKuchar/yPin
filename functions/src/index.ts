import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as geofirestore from 'geofirestore';
import GeoPoint = admin.firestore.GeoPoint;

admin.initializeApp()

export const fetchTop = functions.https.onRequest(async (request, response) => {
  functions.logger.info("fetchTop request", {"request" : request.body})
  const {latitude, longitude} = request.body.data
  const firestore = admin.firestore()
  try {
    let results : any[] = []
    // const collection = firestore.collection('ads')
    const colGeoAds = geofirestore.initializeApp(firestore).collection('ads')
    const refId = colGeoAds.doc().id
    // const refId = collection.doc().id
    let limit = 5
    functions.logger.debug("fetchTop before fetches", {"limit" : limit, "refID" : refId, "latitude" : latitude, "longitude" : longitude})

    // const query1 = await collection.where("uid", ">", refId).limit(limit).get()
    // limit = limit - query1.size
    // query1.forEach(function (doc) {
    //   results.push(doc.data())
    // })

    // const geoQuery1 = await colGeoAds.near({center: new GeoPoint(latitude, longitude)})
    //     .where("uid", ">", refId)
    //     .limit(limit)
    //     .get()
    colGeoAds.add({
      name: 'GeoFirestore',
      score: 100,
      coordinates: new GeoPoint(latitude, longitude)
    }).then(function (valew) {
      functions.logger.debug("fetchTop fetch geolocation -1", {"limit" : limit, "refID" : refId})
    }).catch(function (reason) {
      functions.logger.error("fetchTop fetch geolocation -1", {"error" : reason})
    })
    // const geoQuery1 = await colGeoAds.near({center: new GeoPoint(latitude, longitude), radius: 1000}).get()
    colGeoAds.near({center: new GeoPoint(latitude, longitude), radius: 1000}).get()
        .then(function (value) {
          value.forEach(function (snap) {
            functions.logger.debug("fetchTop fetch geolocation 1", {"limit" : limit, "refID" : refId, "data" : snap.data})
          })
          functions.logger.debug("fetchTop fetch geolocation 2", {"limit" : limit, "refID" : refId, "GeoQuerySize" : value.size})

          functions.logger.debug("fetchTop fetch result", {"refID" : refId, "Result" : results})
          response.json({result: results})
    }).catch(function (reason) {
      functions.logger.error("fetchTop fetch geolocation 3", {"error" : reason})
    })
    // limit = limit - geoQuery1.size
    // functions.logger.debug("fetchTop fetch geolocation 1", {"limit" : limit, "refID" : refId, "GeoQuerySize" : geoQuery1.size})
    // geoQuery1.forEach(function (doc) {
    //   functions.logger.debug("fetchTop fetch geolocation 1", {"QueryDocSnapshot" : doc})
    // })

    // functions.logger.debug("fetchTop fetch1", {"limit" : limit, "refID" : refId, "QuerySize" : query1.size, "ResultSize" : results.length})
    // if (limit > 0) {
    //   const query2 = await collection.where("uid", "<=", refId).limit(limit).get()
    //   query2.forEach(function (doc) {
    //     results.push(doc.data())
    //   })
    //   functions.logger.debug("fetchTop fetch2", {"limit" : limit, "refID" : refId, "QuerySize" : query2.size, "ResultSize" : results.length})
    // }

    // functions.logger.debug("fetchTop fetch result", {"refID" : refId, "Result" : results})
    // response.json({result: results})
  } catch(e) {
    functions.logger.error("fetchTop request fail", {"error" : e})
    response.status(500).send(e)
  }
});
