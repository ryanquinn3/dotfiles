# Color Palettes Reference

## Default Palette (Platform-Agnostic)

<table>
<tr><th>Component Type</th><th>Background</th><th>Stroke</th><th>Example</th></tr>
<tr><td>Frontend/UI</td><td><code>#a5d8ff</code></td><td><code>#1971c2</code></td><td>Next.js, React apps</td></tr>
<tr><td>Backend/API</td><td><code>#d0bfff</code></td><td><code>#7048e8</code></td><td>API servers, processors</td></tr>
<tr><td>Database</td><td><code>#b2f2bb</code></td><td><code>#2f9e44</code></td><td>PostgreSQL, MySQL, MongoDB</td></tr>
<tr><td>Storage</td><td><code>#ffec99</code></td><td><code>#f08c00</code></td><td>Object storage, file systems</td></tr>
<tr><td>AI/ML Services</td><td><code>#e599f7</code></td><td><code>#9c36b5</code></td><td>ML models, AI APIs</td></tr>
<tr><td>External APIs</td><td><code>#ffc9c9</code></td><td><code>#e03131</code></td><td>Third-party services</td></tr>
<tr><td>Orchestration</td><td><code>#ffa8a8</code></td><td><code>#c92a2a</code></td><td>Workflows, schedulers</td></tr>
<tr><td>Validation</td><td><code>#ffd8a8</code></td><td><code>#e8590c</code></td><td>Validators, checkers</td></tr>
<tr><td>Network/Security</td><td><code>#dee2e6</code></td><td><code>#495057</code></td><td>VPC, IAM, firewalls</td></tr>
<tr><td>Classification</td><td><code>#99e9f2</code></td><td><code>#0c8599</code></td><td>Routers, classifiers</td></tr>
<tr><td>Users/Actors</td><td><code>#e7f5ff</code></td><td><code>#1971c2</code></td><td>User ellipses</td></tr>
<tr><td>Message Queue</td><td><code>#fff3bf</code></td><td><code>#fab005</code></td><td>Kafka, RabbitMQ, SQS</td></tr>
<tr><td>Cache</td><td><code>#ffe8cc</code></td><td><code>#fd7e14</code></td><td>Redis, Memcached</td></tr>
<tr><td>Monitoring</td><td><code>#d3f9d8</code></td><td><code>#40c057</code></td><td>Prometheus, Grafana</td></tr>
</table>

## AWS Palette

<table>
<tr><th>Service Category</th><th>Background</th><th>Stroke</th></tr>
<tr><td>Compute (EC2, Lambda, ECS)</td><td><code>#ff9900</code></td><td><code>#cc7a00</code></td></tr>
<tr><td>Storage (S3, EBS)</td><td><code>#3f8624</code></td><td><code>#2d6119</code></td></tr>
<tr><td>Database (RDS, DynamoDB)</td><td><code>#3b48cc</code></td><td><code>#2d3899</code></td></tr>
<tr><td>Networking (VPC, Route53)</td><td><code>#8c4fff</code></td><td><code>#6b3dcc</code></td></tr>
<tr><td>Security (IAM, KMS)</td><td><code>#dd344c</code></td><td><code>#b12a3d</code></td></tr>
<tr><td>Analytics (Kinesis, Athena)</td><td><code>#8c4fff</code></td><td><code>#6b3dcc</code></td></tr>
<tr><td>ML (SageMaker, Bedrock)</td><td><code>#01a88d</code></td><td><code>#017d69</code></td></tr>
</table>

## Azure Palette

<table>
<tr><th>Service Category</th><th>Background</th><th>Stroke</th></tr>
<tr><td>Compute</td><td><code>#0078d4</code></td><td><code>#005a9e</code></td></tr>
<tr><td>Storage</td><td><code>#50e6ff</code></td><td><code>#3cb5cc</code></td></tr>
<tr><td>Database</td><td><code>#0078d4</code></td><td><code>#005a9e</code></td></tr>
<tr><td>Networking</td><td><code>#773adc</code></td><td><code>#5a2ca8</code></td></tr>
<tr><td>Security</td><td><code>#ff8c00</code></td><td><code>#cc7000</code></td></tr>
<tr><td>AI/ML</td><td><code>#50e6ff</code></td><td><code>#3cb5cc</code></td></tr>
</table>

## GCP Palette

<table>
<tr><th>Service Category</th><th>Background</th><th>Stroke</th></tr>
<tr><td>Compute (GCE, Cloud Run)</td><td><code>#4285f4</code></td><td><code>#3367d6</code></td></tr>
<tr><td>Storage (GCS)</td><td><code>#34a853</code></td><td><code>#2d8e47</code></td></tr>
<tr><td>Database (Cloud SQL, Firestore)</td><td><code>#ea4335</code></td><td><code>#c53929</code></td></tr>
<tr><td>Networking</td><td><code>#fbbc04</code></td><td><code>#d99e04</code></td></tr>
<tr><td>AI/ML (Vertex AI)</td><td><code>#9334e6</code></td><td><code>#7627b8</code></td></tr>
</table>

## Kubernetes Palette

<table>
<tr><th>Component</th><th>Background</th><th>Stroke</th></tr>
<tr><td>Pod</td><td><code>#326ce5</code></td><td><code>#2756b8</code></td></tr>
<tr><td>Service</td><td><code>#326ce5</code></td><td><code>#2756b8</code></td></tr>
<tr><td>Deployment</td><td><code>#326ce5</code></td><td><code>#2756b8</code></td></tr>
<tr><td>ConfigMap/Secret</td><td><code>#7f8c8d</code></td><td><code>#626d6e</code></td></tr>
<tr><td>Ingress</td><td><code>#00d4aa</code></td><td><code>#00a888</code></td></tr>
<tr><td>Node</td><td><code>#303030</code></td><td><code>#1a1a1a</code></td></tr>
<tr><td>Namespace</td><td><code>#f0f0f0</code></td><td><code>#c0c0c0</code> (dashed)</td></tr>
</table>

## Diagram Type Suggestions

<table>
<tr><th>Diagram Type</th><th>Recommended Layout</th><th>Key Elements</th></tr>
<tr><td>Microservices</td><td>Vertical flow</td><td>Services, databases, queues, API gateway</td></tr>
<tr><td>Data Pipeline</td><td>Horizontal flow</td><td>Sources, transformers, sinks, storage</td></tr>
<tr><td>Event-Driven</td><td>Hub-and-spoke</td><td>Event bus center, producers/consumers</td></tr>
<tr><td>Kubernetes</td><td>Layered groups</td><td>Namespace boxes, pods inside deployments</td></tr>
<tr><td>CI/CD</td><td>Horizontal flow</td><td>Source -> Build -> Test -> Deploy -> Monitor</td></tr>
<tr><td>Network</td><td>Hierarchical</td><td>Internet -> LB -> VPC -> Subnets -> Instances</td></tr>
<tr><td>User Flow</td><td>Swimlanes</td><td>User actions, system responses, external calls</td></tr>
</table>
