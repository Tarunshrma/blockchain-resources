const EnglishAuction = artifacts.require("EnglishAuction");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("EnglishAuction", function (/* accounts */) {
  it("should assert true", async function () {
    await EnglishAuction.deployed();
    return assert.isTrue(true);
  });
});
