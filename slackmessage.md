I reviewed the dataset and found several data quality issues impacting the analysis. The most critical problem is that all the data is from 2021, meaning we have no users created in the last six months, which affects questions about recent activity. Additionally, there are duplicate _id values in the users table and many nulls in key columns like user_id and role, which complicate accurate joins and calculations. To move forward, we need more recent data, clear guidance on handling duplicates and nulls, and possibly a validation process to prevent these issues in the future.

To move forward, I need clarification on the following:

Is more recent data available, and if so, can it be included in the dataset?
How should duplicate users and null values be handled? For example:
Should duplicates be flagged or excluded?
Are there acceptable default values for missing data?
Who owns the data pipelines, and can we collaborate with them to implement validation steps?