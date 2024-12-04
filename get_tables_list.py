from google.cloud import bigquery
import json
import hcl2

def get_tables_of_business_function(
        bigquery_billing_project_id, 
        bigquery_billing_dataset_id, 
        bigquery_billing_table_id,
        label_key,
        tfvars_data
):

        query = f"""
                SELECT 
                l.value as label_value, 
                ARRAY_AGG(DISTINCT CONCAT("projects/", project.number)) p_list, 
                count(DISTINCT project.id) AS count_p,
                FROM `{bigquery_billing_project_id}.{bigquery_billing_dataset_id}.{bigquery_billing_table_id}` , UNNEST(labels) AS l
                WHERE l.key = "{label_key}"
                GROUP BY 1
                ORDER BY count_p desc
                LIMIT 4
        """
        
        bq_client = bigquery.Client()
        query_job = bq_client.query(query)
        rows = query_job.result()

        for row in rows:
            try:
                tfvars_data["budgets_config"][row["label_value"]]["projects"] = row["p_list"]
            except Exception as e:
                # if new business function is created???
                print("Error: ", e)
                print("\n")
        
        with open("terraform.tfvars.json", "w") as tfvars:
            tfvars = json.dump(tfvars_data, tfvars, indent=4)


if __name__== "__main__":
    with open("config.json") as config_data:
        config_data = json.load(config_data)

    with open("terraform.tfvars.json") as tfvars_data:
        tfvars_data = json.load(tfvars_data)
    

    bq_billing_project_id = config_data["bigquery_billing_project_id"]
    bq_billing_dataset_id = config_data["bigquery_billing_dataset_id"]
    bq_billing_table_id = config_data["bigquery_billing_table_id"]
    label_key = config_data["label_key"]
    get_tables_of_business_function(bq_billing_project_id, bq_billing_dataset_id, bq_billing_table_id, label_key, tfvars_data)
