from aws_cdk import (
    Stack,
    RemovalPolicy,
    aws_s3,
    aws_dynamodb,
)
from constructs import Construct
import os


class TerraformBackendStack(Stack):

    # 適宜変更
    ORGANIZATION = 'zoo200'
    PREFIX = 'terraform-backend'

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        env = os.environ['TF_ENV']

        if not (env == 'dev' or env == 'prod'):
            raise Exception('Param TF_ENV Error!')

        resouce_name = '-'.join([self.ORGANIZATION, env, self.PREFIX])

        class_name = self.__class__.__name__

        # tfstate保存用のS3バケット
        aws_s3.Bucket(
            self,
            class_name + 'S3Bucket',
            versioned=True,
            bucket_name=resouce_name,
            encryption=aws_s3.BucketEncryption.S3_MANAGED,
            block_public_access=aws_s3.BlockPublicAccess(
                    block_public_acls=True,
                    block_public_policy=True,
                    ignore_public_acls=True,
                    restrict_public_buckets=True
            ),
            removal_policy=RemovalPolicy.DESTROY,
        )

        # Terraform実行時の排他制御用のDynamoDB
        aws_dynamodb.Table(
            self,
            class_name + 'DynamoDB',
            table_name=resouce_name,
            partition_key=aws_dynamodb.Attribute(
                name="LockID",
                type=aws_dynamodb.AttributeType.STRING
            ),
            removal_policy=RemovalPolicy.DESTROY,
            billing_mode=aws_dynamodb.BillingMode.PAY_PER_REQUEST
        )
