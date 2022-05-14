const StarNotary = artifacts.require("starNotary");

let accounts;
var owner;
let instance;

contract ("StarNotary", async (accs) =>{
    accounts = accs;
    owner = accounts[0] 
    
});

it("Check Name of Star",async () =>{
    instance = await StarNotary.deployed();    
    let starName = await instance.starName.call(); 
    assert.equal(starName,"TS Star");
});

it("Claim Star",async () =>{
    instance = await StarNotary.deployed();
    await instance.claimStar({from: owner})
    assert.equal(await instance.owner.call(),owner);
})

it("Change ownership",async () =>{
    instance = await StarNotary.deployed();
    await instance.claimStar({from: owner})
    assert.equal(await instance.owner.call(),owner);

    await instance.claimStar({from: accounts[1]})
    assert.equal(await instance.owner.call(),accounts[1]);
})

