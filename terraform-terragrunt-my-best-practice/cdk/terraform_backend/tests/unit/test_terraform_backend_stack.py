import aws_cdk as core
import aws_cdk.assertions as assertions

from terraform_backend.terraform_backend_stack import TerraformBackendStack

# example tests. To run these tests, uncomment this file along with the example
# resource in terraform_backend/terraform_backend_stack.py
def test_sqs_queue_created():
    app = core.App()
    stack = TerraformBackendStack(app, "terraform-backend")
    template = assertions.Template.from_stack(stack)

#     template.has_resource_properties("AWS::SQS::Queue", {
#         "VisibilityTimeout": 300
#     })
