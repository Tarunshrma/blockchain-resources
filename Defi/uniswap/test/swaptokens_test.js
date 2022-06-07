const swaptokensTest = artifacts.require("swaptokensTest");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("swaptokensTest", function (/* accounts */) {
  it("should assert true", async function () {
    await swaptokensTest.deployed();
    return assert.isTrue(true);
  });
});
