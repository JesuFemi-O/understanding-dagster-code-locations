from dagster import asset

@asset
def roas_report():
    print("return on ad spend asset")


@asset
def churn_prediction_model():
    print("churn prediction asset")