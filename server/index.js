const express = require('express');
const https = require('https');
const { resolve } = require('path');

const app = express();
const port = 3498;

const word_url = "https://fly.wordfinderapi.com/api/search?";

function get_words(start, end, length) {
    return new Promise((resolve, reject) => {
        let url = word_url + "starts_with=" + start + "&ends_with=" + end + "&length=" + length + "&word_sorting=points&group_by_length=false&page_size=99999&dictionary=all_en";
        console.info("[get]" + url);

        https.get(url, (resp) => {
            let body = "";

            resp.on("data", (chunk) => {
                body += chunk;
            });

            resp.on("end", () => {
                console.info(">> got response from server");
                try {
                    console.info(">> parse response JSON");
                    let json_data = JSON.parse(body);
                    resolve(json_data);
                }
                catch (error) {
                    console.error("XX Error when parsing JSON data: " + error);
                    console.error("------------------ BODY ------------------");
                    console.error(body);
                    console.error("---------------- END BODY ----------------");
                    reject("Error when parse JSON data");
                }
            });

            resp.on("error", (error) => {
                reject("Error on response: " + error);
            });
        });
    });
}

function search_words(word, length) {
    return new Promise((resolve, reject) => {
        let url = word_url + "letters=" + word + "&length=" + length + "&word_sorting=points&group_by_length=false&page_size=99999&dictionary=all_en";
        console.info("[search]" + url);

        https.get(url, (resp) => {
            let body = "";

            resp.on("data", (chunk) => {
                body += chunk;
            });

            resp.on("end", () => {
                console.info(">> got response from server");
                try {
                    console.info(">> parse response JSON");
                    let json_data = JSON.parse(body);
                    resolve(json_data);
                }
                catch (error) {
                    console.error("XX Error when parsing JSON data: " + error);
                    console.error("------------------ BODY ------------------");
                    console.error(body);
                    console.error("---------------- END BODY ----------------");
                    reject("Error when parse JSON data");
                }
            });

            resp.on("error", (error) => {
                reject("Error on response: " + error);
            });
        });
    });
}

app.use(function(req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, Content-Length, X-Requested-With');

    //intercepts OPTIONS method
    if ('OPTIONS' === req.method) {
        //respond with 200
        res.send(200);
    }
    else {
        //move on
        next();
    }
});

app.get('/get-words/start/:start/end/:end/length/:length', async (req, res) => {
    let start = req.params.start;
    let end = req.params.end;
    let length = req.params.length;

    if (start === undefined || end === undefined || length === undefined) {
        res.status(502);
        res.send("Invalid data");
    }
    else {
        // ensure length is minimum 5
        if (length < 5) {
            length = 5;
        }

        // try to get the data
        let words = "";
        await get_words(start, end, length).then((resp) => {
            words = resp;
        });

        // response
        res.status(200);
        res.send(words);
    }
});

app.get('/search-words/word/:word/length/:length', async (req, res) => {
    let word = req.params.word;
    let length = req.params.length;

    if (word === undefined || length === undefined) {
        res.status(502);
        res.send("Invalid data");
    }
    else {
        // ensure length is minimum 5
        if (length < 5) {
            length = 5;
        }

        // try to get the data
        let words = "";
        await search_words(word, length).then((resp) => {
            words = resp;
        });

        // response
        res.status(200);
        res.send(words);
    }
});

app.listen(port, (error) => {
    if (!error) {
        console.log("wxrdle-api is successfully running on port=" + port);
    }
    else {
        console.error("Error occured, unabled to start API services: " + error);
    }
});