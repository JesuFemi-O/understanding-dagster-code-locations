from dagster import asset

@asset
def churn_model():
    print("ML churn asset")


@asset
def predelinquency_model():
    print("ML customer success asset")