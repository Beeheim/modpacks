const { dependencies } = require('../vanilla-plus/optional-pack/manifest.json');
const axios = require('axios');
const rateLimit = require('axios-rate-limit');
const chalk = require('chalk');




async function parseDeps() {
    let parsedDependencies = [];
    if (Array.isArray(dependencies) && dependencies.every(item => typeof item === 'string')) {
        parsedDependencies = dependencies.map(dependency => {
            const parts = dependency.split("-");
            if (parts.length >= 2) {
                return {
                    author: parts[0],
                    package: parts.slice(1, -1).join("-"),  // package name can contain "-"
                    version: parts[parts.length - 1]
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



async function processDependencies(deps) {
    const delay = ms => new Promise(res => setTimeout(res, ms));
    const thunderstore = rateLimit(axios.create(), { maxRequests: 1, perMilliseconds: 1000 });
    const rateLimitErrorCode = 429
    const oneminute = 60000
    // console.log(deps);
    if (deps.length === 0) {
        console.log(chalk.red('deps is empty'));
        return;
    }
    for (const mod of deps) {
        try {
            const response = await thunderstore.get(`https://valheim.thunderstore.io/api/experimental/package/${mod.author}/${mod.package}/`, {
                headers: {
                    'Accept': 'application/json'
                }
            });
            if (response.data.latest.version_number === mod.version) {
                console.log(chalk.cyan(`${mod.package}: version matches: ${mod.version}`));
            } else {
                console.log(chalk.yellow(`${mod.package}: new version available: ${mod.version} -> ${response.data.latest.version_number}`));
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

parseDeps().then(processDependencies);



// parsedDependencies.forEach(mod => {
//     thunderstore.get(`https://valheim.thunderstore.io/api/experimental/package/${mod.author}/${mod.package}/`, {
//         headers: {
//             'Accept': 'application/json'
//         }
//     })
//         .then(response => {
//             if (response.data.latest.version_number === mod.version) {
//                 console.log(`${mod.package}: version matches: ${mod.version}`)
//             } else {
//                 console.log(`${mod.package}: new version available: ${mod.version} -> ${response.data.latest.version_number}`)
//             }
//         })
//         .catch(error => {
//             console.error(error);
//         });
// });