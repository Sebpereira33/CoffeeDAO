use aiken/dict
use aiken/hash.{Blake2b_224, Hash}
use aiken/interval.{Finite, Interval, IntervalBound, PositiveInfinity}
use aiken/list
use aiken/transaction.{Output, ScriptContext, Transaction, ValidityRange} as tx
use aiken/transaction/credential.{VerificationKey, VerificationKeyCredential}
use aiken/transaction/value

type Action {
  Basic
  Premium
  Burn
}

type POSIXTime =
  Int

validator {
  fn mint_coffee(redeemer: Action, context: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = context

    let Transaction { mint, outputs, validity_range, extra_signatories, .. } =
      transaction

    expect tx.Mint(policy_id) = purpose

    expect [(_, amount)] =
      mint
        |> value.tokens(policy_id)
        |> dict.to_list()

    when redeemer is {
      Basic ->
        check_minting_conditions(
          outputs,
          extra_signatories,
          validity_range,
          50000000,
          amount,
        )
      Premium ->
        check_minting_conditions(
          outputs,
          extra_signatories,
          validity_range,
          70000000,
          amount,
        )
      Burn -> amount == -1
    }
  }
}

fn check_minting_conditions(
  outputs: List<Output>,
  signatories: List<Hash<Blake2b_224, VerificationKey>>,
  range: ValidityRange,
  nft_cost: Int,
  mint_amount: Int,
) -> Bool {
  let value_paid =
    outputs
      |> list.filter(
           fn(output) {
             expect VerificationKeyCredential(hash) =
               output.address.payment_credential
             hash == #"5032b71b5b54ab728a9e8a7ffd9e722e7349fd275d001105c5eedadb"
           },
         )
      |> list.foldr(fn(a, b) { value.lovelace_of(a.value) + b }, 0)
  let must_be_signed =
    list.has(
      signatories,
      #"12c15099b30cd9d50f0b917f6b87acc47b62b4c6952ceb7bef91b922",
    )
  // 1690848000000 is August 1st 2023 midnight GMT
  let before_deadline = must_mint_before_deadline(range, 1690848000000)
  before_deadline && value_paid == nft_cost && must_be_signed && mint_amount == 1
}

fn must_mint_before_deadline(range: ValidityRange, deadline: POSIXTime) {
  when range.upper_bound.bound_type is {
    Finite(tx_upper) -> tx_upper <= deadline
    _ -> False
  }
}

test mint_after_deadline_fails() {
  let range: ValidityRange =
    Interval {
      lower_bound: IntervalBound { bound_type: Finite(2), is_inclusive: True },
      upper_bound: IntervalBound { bound_type: Finite(5), is_inclusive: True },
    }

  !must_mint_before_deadline(range, 4)
}

test mint_at_deadline_succeeds() {
  let range: ValidityRange =
    Interval {
      lower_bound: IntervalBound { bound_type: Finite(2), is_inclusive: True },
      upper_bound: IntervalBound { bound_type: Finite(4), is_inclusive: True },
    }

  must_mint_before_deadline(range, 4)
}

test mint_before_deadline_succeeds() {
  let range: ValidityRange =
    Interval {
      lower_bound: IntervalBound { bound_type: Finite(2), is_inclusive: True },
      upper_bound: IntervalBound { bound_type: Finite(3), is_inclusive: True },
    }

  must_mint_before_deadline(range, 4)
}

test mint_with_infinite_upper_fails() {
  let range: ValidityRange =
    Interval {
      lower_bound: IntervalBound { bound_type: Finite(2), is_inclusive: True },
      upper_bound: IntervalBound {
        bound_type: PositiveInfinity,
        is_inclusive: True,
      },
    }

  !must_mint_before_deadline(range, 4)
}
