from dagster import asset

@asset
def general_ledger():
    print("General ledger asset")


@asset
def chargebacks():
    print("chargebacks asset")