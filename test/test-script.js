var Main = artifacts.require("main");
var P2P = artifacts.require("p2p")
var rand = require('random-seed').create("seed");

function shuffle(array) {
    let currentIndex = array.length,  randomIndex;
  
    // While there remain elements to shuffle.
    while (currentIndex != 0) {
  
      // Pick a remaining element.
      randomIndex = Math.floor(rand.floatBetween(0, 1) * currentIndex);
      currentIndex--;
  
      // And swap it with the current element.
      [array[currentIndex], array[randomIndex]] = [
        array[randomIndex], array[currentIndex]];
    }
  
    return array;
  }

contract("main", (accounts) => {
  let p2p, main;

  before(async () => {

        p2p = await P2P.deployed()
        main = await Main.deployed()
    });

    describe("Cwk: Trading Scenario", async () => {
        before("Register 20 Users", async () => {

          console.log("LENGTH: "+accounts.length)
          for(let i = 0; i < 20; i++) {

            res = await main.registerProsumer({from: accounts[i]})
            res = await main.deposit({from: accounts[i], value: 30000000000000000000})
          }
        });

        let beforeUsers = [];
        let afterUsers = [];
        let beforeSum = 0;
        let afterSum = 0;
        it("Performs scenario", async () => {
            users = []
            for (let i = 0; i < 10; i++) {
                // console.log(i)
                // let energyStatus = Math.floor(Math.random() *(6 - 1 + 1) + 1)
                let energyBalance = await rand.intBetween(1, 6)
                beforeSum -= energyBalance
                // let energyStatus = 10

                await users.push({"id": accounts[i], "energyBalance": -energyBalance, "etherBalance": 30000000000000000000})
                await main.setEnergyStatus(energyBalance, {from: accounts[i]})
                await main.deposit({from: accounts[i], value: 30000000000000000000})
                energyStatus = await main.checkEnergyStatus({from: accounts[i]})
                // console.log(energyStatus.toString())
                // assert(energyStatus < 0, "Energy Status should be less than 0")

                res = await main.checkEtherStatus({from: accounts[i]})
                // console.log(res)
                assert.equal(res.toNumber(), 30, "The account should have a balance of 30000000000000000000.");
    
            }
            for (let i = 10; i < 20; i++) {
                // console.log(i)
                // let energyStatus = Math.floor(Math.random() *(8 - 1 + 1) + 1)
                let energyBalance = rand.intBetween(1, 8)
                beforeSum += energyStatus
                // let energyStatus = 10
                users.push({"id": accounts[i], "energyBalance": energyBalance, balance: 30000000000000000000})
                await main.setEnergyStatus(energyBalance, {from: accounts[i]})
                await main.deposit({from: accounts[i], value: 30000000000000000000})
                energyBalance = await main.checkEnergyStatus({from: accounts[i]})
                // assert(energyStatus > 0, "Energy Status should be greater than 0")
                // console.log(energyStatus.toString())

                res = await main.checkEtherStatus({from: accounts[i]})
                assert.equal(res.toNumber(), 30, "The account should have a balance of 30000000000000000000.");
    
            }
            // console.log(users)
            for (let i = 0; i < accounts.length; i++) {
                balance = (await main.checkEtherStatus({from: accounts[i]})).toString()
                energyBalance = (await main.checkEnergyStatus({from: accounts[i]})).toString()
                // tokens = (await main.checkTokens({from: accounts[i]})).toString()
                beforeUsers.push({"id": users[i]["id"], "energyBalance": energyBalance, "etherBalance": balance})
            }
            shuffle(users)
            // console.log(users.length)
   
            console.log(users.length)
            for (let i = 0; i < users.length; i++) {
                // console.log(users[i]["energyStatus"])
                await main.energyRequest(users[i]["energyBalance"], {from: users[i]["id"]})
                for (let j = 0; j < users.length; j++) {
                    // console.log(users[j]["energyStatus"], users[j]["balance"])
                    users[j]["energyBalance"] = (await main.checkEnergyStatus({from: users[j]["id"]})).toString()
                    users[j]["etherBalance"] = (await main.get({from: users[j]["id"]})).toString()
                    // users[j]["tokens"] = (await main.checkTokens({from: users[j]["id"]})).toString()
                }
            }

            for (let i = 0; i < accounts.length; i++) {
                balance = (await main.checkEtherStatus({from: accounts[i]})).toString()
                energyBalance = (await main.checkEnergyStatus({from: accounts[i]})).toString()
                // tokens = (await main.checkTokens({from: accounts[i]})).toString()
                afterUsers.push({"ID": accounts[i], "energyBalance": energyBalance, "etherBalance": balance})

                // console.log(users[i]["ID"], users[i]["balance"], users[i]["energyStatus"], users[i]["tokens"])
                // console.log("\n")


                afterSum += parseInt(users[i]["energyBalance"].toString())
                // afterUsers.push({"ID": users[i]["ID"], "energyStatus": users[i]["energyStatus"], "balance": users[i]["balance"]})
            }
            // console.log(afterUsers.length)
        })

        after("Withdraw Ethers", async () => {
            for (let i = 0; i < accounts.length; i++) {
                // console.log(i)
                // balance = await main.checkBalance({from: users[i]["ID"]})
                balance = (await main.checkEtherStatus({from: accounts[i]})).toString()
                energyStatus = (await main.checkEnergyStatus({from: accounts[i]})).toString()
                // tokens = (await main.checkTokens({from: accounts[i]})).toString()

                console.log(beforeUsers[i]["id"], beforeUsers[i]["etherBalance"], beforeUsers[i]["energyBalance"])
                console.log(accounts[i], balance, energyStatus)
                console.log("\n")

                res = await main.withdraw({from: accounts[i]})
            }
            console.log(beforeSum)
            console.log(afterSum)
          });

    });
});