import pulumi
import pulumi_aws as aws

bucket = aws.s3.Bucket(
    "pulumi-buildkite-plugin-test",
    tags={
        "pulumi:project": pulumi.get_project(),
        "pulumi:stack": pulumi.get_stack()
    }
)

pulumi.export('bucket_name', bucket.id)
