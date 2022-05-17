from pulumi_policy import (
    EnforcementLevel,
    PolicyPack,
    ReportViolation,
    ResourceValidationArgs,
    ResourceValidationPolicy,
)

def must_have_pulumi_tags_validator(
    args: ResourceValidationArgs, report_violation: ReportViolation
) -> None:
    required_tags=["pulumi:project", "pulumi:stack"]
    if args.resource_type == "aws:s3/bucket:Bucket":
        tags = args.props.get("tags")
        if not (tags and set(required_tags).issubset(set(tags.keys()))):
            report_violation(
                f"All instances of {args.resource_type} must have the following tags: {required_tags}. This one has {list(tags.keys())}."
            )

must_have_pulumi_tags = ResourceValidationPolicy(
    name="must-have-pulumi-tags",
    description="All our taggable resources should have tags for the Pulumi project and stack that created them.",
    validate=must_have_pulumi_tags_validator
)

PolicyPack(
    name="pulumi-buildkite-plugin-test-policy",
    enforcement_level=EnforcementLevel.MANDATORY,
    policies=[
        must_have_pulumi_tags,
    ],
)
