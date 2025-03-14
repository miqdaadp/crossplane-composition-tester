# Copyright 2023 Swisscom (Schweiz) AG

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

@PolicyScheduler
Feature: Policy scheduler composition
  Tests the policy scheduler composition

  Background:
    Given input claim xr.yaml
    # following step is optional: default input composition is composition.yaml 
    And input composition composition.yaml
    # following step is optional: default input functions is functions.yaml
    And input functions functions.yaml
    Then check that no resources are provisioning

  @normal
  Scenario: Test the role and policies as per the schedule

    # render 1
    When crossplane renders the composition
    Then check that 2 resources are provisioning
    And check that resource role has parameters
    | param name      | param value                 |
    | scheduleFrom    | 2025-03-14T07:35:05Z       |
    | scheduleUntil   | 2025-03-15T07:35:05Z       |
    | metadata.name   | scheduler-claim |
    # | spec.forProvider.permissionsBoundary | {regexp}*/sc-policy-cdk-pipeline-permission-boundary |

    # render 2
    Given change observed resource role with status NOT READY and parameters
      | param name            | param value |
      | status.atProvider.arn | arn::role   |
    And change observed resource default-policy with status NOT READY and parameters
      | param name            | param value         |
      | status.atProvider.arn | arn::default-policy |
    When crossplane renders the composition
    Then check that 2 resources are provisioning and they are
      | resource-name  |
      | role           |
      | default-policy |


    # render 3
    Given change all observed resources with status READY
    When crossplane renders the composition
    Then log desired resources

    # render 4
    Given change all observed resources with status NOT READY
    When crossplane renders the composition
    Then log desired resources