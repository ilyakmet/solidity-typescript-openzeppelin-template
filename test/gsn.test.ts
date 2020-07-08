const { accounts, contract, web3 } = require("@openzeppelin/test-environment");

const gsn = require("@openzeppelin/gsn-helpers");

const Counter = contract.fromArtifact("Counter");
const Recipient = contract.fromArtifact("Recipient");
const IRelayHub = contract.fromArtifact("IRelayHub");

describe("GSNRecipient", function() {
  const [sender, _] = accounts;

  before(async function() {
    await gsn.deployRelayHub(web3, { from: sender });
  });

  context("when relay-called", function() {
    beforeEach(async function() {
      this.counter = await Counter.new();
      this.recipient = await Recipient.new(this.counter.address);

      await gsn.fundRecipient(web3, { recipient: this.recipient.address });
      this.relayHub = await IRelayHub.at(
        "0xD216153c06E857cD7f72665E0aF1d7D82172F494"
      );
    });

    it("increase", async function() {
      const recipientPreBalance = await this.relayHub.balanceOf(
        this.recipient.address
      );

      const senderPreBalance = await web3.eth.getBalance(_);

      const tx = await this.recipient.sendTransaction({
        from: _,
        data: "0xe8927fbc",
        useGSN: true,
      });

      const v = await this.counter.value();

      const recipientPostBalance = await this.relayHub.balanceOf(
        this.recipient.address
      );

      const senderPostBalance = await web3.eth.getBalance(_);

      console.log({
        recipientPreBalance: recipientPreBalance.toString(),
        recipientPostBalance: recipientPostBalance.toString(),
        senderPreBalance: senderPreBalance.toString(),
        senderPostBalance: senderPostBalance.toString(),
        v: v.toString(),
        tx,
        _,
        sender,
      });
    });
  });
});
