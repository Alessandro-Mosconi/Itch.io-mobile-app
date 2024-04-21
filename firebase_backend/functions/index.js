const functions = require('firebase-functions');
const admin = require('firebase-admin'); //added for FCM
const fetch = require('node-fetch');

const RSSParser = require('rss-parser');

admin.initializeApp();

exports.fetchRSSFeedAndNotify = functions.https.onRequest(async (request, response) => {
    const rssParser = new RSSParser();
    const rssUrl = 'https://itch.io/games/free.xml';

    try {
        const res = await fetch(rssUrl);
        const xml = await res.text();
        const feed = await rssParser.parseString(xml);

        console.log('Fetched RSS Feed:', JSON.stringify(feed, null, 2));

        if (feed.items.length > 0) {
            const latestItem = feed.items[0]; // Assuming the first item is the latest
            console.log('Latest News Title:', latestItem.title);

            // Prepare and send a notification about the latest item
            const message = {
                notification: {
                    title: 'New Game Alert!',
                    body: `${latestItem.title} is now available on itch.io!`
                },
                topic: 'new-games'
            };

            await admin.messaging().send(message);
            console.log('Notification sent for:', latestItem.title);
        }

        response.json(feed);
    } catch (error) {
        console.error("Error fetching RSS feed or sending notification:", error);
        response.status(500).send('Failed to fetch RSS feed or send notification');
    }
});
