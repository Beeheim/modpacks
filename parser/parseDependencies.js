const { dependencies } = require('../vanilla-plus/optional-pack/manifest.json');
const axios = require('axios');
const rateLimit = require('axios-rate-limit');
const chalk = require('chalk');


const package = 'https://valheim.thunderstore.io/api/experimental/package'; // This is the url for a single package
const index = 'https://valheim.thunderstore.io/api/experimental/package-index'; // very large index. 160k entries;



async function parseDeps() {
    let parsedDependencies = [];
    if (Array.isArray(dependencies) && dependencies.every(item => typeof item === 'string')) {
        parsedDependencies = dependencies.map(dependency => {
            const parts = dependency.split("-");
            if (parts.length >= 2) {
                return {
                    namespace: parts[0],
                    name: parts.slice(1, -1).join("-"),  // package name can contain "-"
                    version_number: parts[parts.length - 1]
                };
            } else {
                console.log(chalk.red(`Error: Bad entry, parts.length too short\n${parts}`))
            }
        });
        return parsedDependencies;
    } else {
        console.error(chalk.red(`Dependencies must be an array of strings`));
    }
}

async function fetchIndex(indexUrl) {
    console.log(indexUrl);
    const thunderstore = rateLimit(axios.create(), { maxRequests: 1, perMilliseconds: 1000 });
    const oneminute = 60000
    const response = await thunderstore.get(indexUrl, {
        headers: {
            'Accept-Encoding': 'gzip'
        }
    })
        .then(res => {
            console.log(chalk.green(`Index fetched, ${res.data.length} entries`));
            let arr = res.data.split('\n').map(str => {
                try {
                    return JSON.parse(str);
                } catch (error) {
                    console.error(`Failed to parse JSON: ${str}`);
                    return null;
                }
            }).filter(item => item !== null);
            console.log(arr);
            return arr;
        })
        .catch(error => {
            console.error(error);
        });
    return response;
}

async function processDependencies(deps) {
    const delay = ms => new Promise(res => setTimeout(res, ms));
    const thunderstore = rateLimit(axios.create(), { maxRequests: 1, perMilliseconds: 1000 });
    const rateLimitErrorCode = 429
    const oneminute = 60000
    if (deps.length === 0) {
        console.log(chalk.red('deps is empty'));
        return;
    }
    for (const mod of deps) {
        try {
            const response = await thunderstore.get(
        `${package}/${mod.namespace}/${mod.name}/`, {
                headers: {
                    'Accept': 'application/json'
                }
            });
            if (response.data.latest.version_number === mod.version_number) {
                console.log(chalk.cyan(`${mod.name}: version matches: ${mod.version_number}`));
            } else {
                console.log(chalk.yellow(`${mod.name}: new version available: ${mod.version_number} -> ${response.data.latest.version_number}`));
            }
        } catch (error) {
            if (error.response && error.response.status === rateLimitErrorCode) {
                console.log(chalk.red('Rate limit exceeded, waiting for 60 seconds'));
                await delay(oneminute); // Wait for 60 seconds
            } else {
                console.error(error);
            }
        }
    }
}

fetchIndex(index).then(processDependencies);
