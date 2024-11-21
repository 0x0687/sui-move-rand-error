#[test_only]
module random_example::random_example_tests;

use sui::random;
use sui::test_scenario;

public struct DummyStruct has key, store {
    id: UID
}

#[test]
fun test_random_example() {
    let mut scenario = test_scenario::begin(@0x0);
    {
        random::create_for_testing(scenario.ctx());
    };
    scenario.end();

    let addr = @0xa;
    let mut scenario = test_scenario::begin(addr);
    {
        let dummy_struct = DummyStruct {
            id: object::new(scenario.ctx())
        };
        transfer::public_transfer(dummy_struct, scenario.sender());
    };
    
    scenario.next_tx(addr);
    {
        let dummy = scenario.take_from_sender<DummyStruct>();
        // OK
        scenario.return_to_sender(dummy);
    };

    scenario.next_tx(addr);
    {
        let dummy = scenario.take_from_sender<DummyStruct>();
        let rand = test_scenario::take_shared<random::Random>(&scenario);
        // OK
        scenario.return_to_sender(dummy);
        test_scenario::return_shared(rand);
    };

    scenario.next_tx(addr);
    {
        let dummy = scenario.take_from_sender<DummyStruct>(); // Fails here
        // FAIL
        scenario.return_to_sender(dummy);
    };

    scenario.end();

    /*
    Test failures:

    Failures in random_example::random_example_tests:

    ┌── test_random_example ──────
    │ error[E11001]: test failure
    │     ┌─ ~/.move/https___github_com_MystenLabs_sui_git_framework__testnet/crates/sui-framework/packages/sui-framework/sources/test/test_scenario.move:231:19
    │     │
    │ 231 │ public native fun take_from_address_by_id<T: key>(scenario: &Scenario, account: address, id: ID): T;
    │     │                   ^^^^^^^^^^^^^^^^^^^^^^^
    │     │                   │
    │     │                   Test was not expected to error, but it aborted with code 4 originating in the module sui::test_scenario rooted here
    │     │                   In this function in sui::test_scenario
    │ 
    │ 
    │ stack trace
    │       test_scenario::take_from_sender(~/.move/https___github_com_MystenLabs_sui_git_framework__testnet/crates/sui-framework/packages/sui-framework/sources/test/test_scenario.move:284)
    │       random_example_tests::test_random_example(./tests/random_example_tests.move:46)
    │ 
    └──────────────────

    Test result: FAILED. Total tests: 1; passed: 0; failed: 1
    */
}
