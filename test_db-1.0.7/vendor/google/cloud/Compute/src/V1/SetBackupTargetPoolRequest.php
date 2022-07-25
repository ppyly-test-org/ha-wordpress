<?php
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: google/cloud/compute/v1/compute.proto

namespace Google\Cloud\Compute\V1;

use Google\Protobuf\Internal\GPBType;
use Google\Protobuf\Internal\RepeatedField;
use Google\Protobuf\Internal\GPBUtil;

/**
 * A request message for TargetPools.SetBackup. See the method description for details.
 *
 * Generated from protobuf message <code>google.cloud.compute.v1.SetBackupTargetPoolRequest</code>
 */
class SetBackupTargetPoolRequest extends \Google\Protobuf\Internal\Message
{
    /**
     * New failoverRatio value for the target pool.
     *
     * Generated from protobuf field <code>optional float failover_ratio = 212667006;</code>
     */
    private $failover_ratio = null;
    /**
     * Project ID for this request.
     *
     * Generated from protobuf field <code>string project = 227560217 [(.google.api.field_behavior) = REQUIRED, (.google.cloud.operation_request_field) = "project"];</code>
     */
    private $project = '';
    /**
     * Name of the region scoping this request.
     *
     * Generated from protobuf field <code>string region = 138946292 [(.google.api.field_behavior) = REQUIRED, (.google.cloud.operation_request_field) = "region"];</code>
     */
    private $region = '';
    /**
     * An optional request ID to identify requests. Specify a unique request ID so that if you must retry your request, the server will know to ignore the request if it has already been completed. For example, consider a situation where you make an initial request and the request times out. If you make the request again with the same request ID, the server can check if original operation with the same request ID was received, and if so, will ignore the second request. This prevents clients from accidentally creating duplicate commitments. The request ID must be a valid UUID with the exception that zero UUID is not supported ( 00000000-0000-0000-0000-000000000000).
     *
     * Generated from protobuf field <code>optional string request_id = 37109963;</code>
     */
    private $request_id = null;
    /**
     * Name of the TargetPool resource to set a backup pool for.
     *
     * Generated from protobuf field <code>string target_pool = 62796298 [(.google.api.field_behavior) = REQUIRED];</code>
     */
    private $target_pool = '';
    /**
     * The body resource for this request
     *
     * Generated from protobuf field <code>.google.cloud.compute.v1.TargetReference target_reference_resource = 523721712 [(.google.api.field_behavior) = REQUIRED];</code>
     */
    private $target_reference_resource = null;

    /**
     * Constructor.
     *
     * @param array $data {
     *     Optional. Data for populating the Message object.
     *
     *     @type float $failover_ratio
     *           New failoverRatio value for the target pool.
     *     @type string $project
     *           Project ID for this request.
     *     @type string $region
     *           Name of the region scoping this request.
     *     @type string $request_id
     *           An optional request ID to identify requests. Specify a unique request ID so that if you must retry your request, the server will know to ignore the request if it has already been completed. For example, consider a situation where you make an initial request and the request times out. If you make the request again with the same request ID, the server can check if original operation with the same request ID was received, and if so, will ignore the second request. This prevents clients from accidentally creating duplicate commitments. The request ID must be a valid UUID with the exception that zero UUID is not supported ( 00000000-0000-0000-0000-000000000000).
     *     @type string $target_pool
     *           Name of the TargetPool resource to set a backup pool for.
     *     @type \Google\Cloud\Compute\V1\TargetReference $target_reference_resource
     *           The body resource for this request
     * }
     */
    public function __construct($data = NULL) {
        \GPBMetadata\Google\Cloud\Compute\V1\Compute::initOnce();
        parent::__construct($data);
    }

    /**
     * New failoverRatio value for the target pool.
     *
     * Generated from protobuf field <code>optional float failover_ratio = 212667006;</code>
     * @return float
     */
    public function getFailoverRatio()
    {
        return isset($this->failover_ratio) ? $this->failover_ratio : 0.0;
    }

    public function hasFailoverRatio()
    {
        return isset($this->failover_ratio);
    }

    public function clearFailoverRatio()
    {
        unset($this->failover_ratio);
    }

    /**
     * New failoverRatio value for the target pool.
     *
     * Generated from protobuf field <code>optional float failover_ratio = 212667006;</code>
     * @param float $var
     * @return $this
     */
    public function setFailoverRatio($var)
    {
        GPBUtil::checkFloat($var);
        $this->failover_ratio = $var;

        return $this;
    }

    /**
     * Project ID for this request.
     *
     * Generated from protobuf field <code>string project = 227560217 [(.google.api.field_behavior) = REQUIRED, (.google.cloud.operation_request_field) = "project"];</code>
     * @return string
     */
    public function getProject()
    {
        return $this->project;
    }

    /**
     * Project ID for this request.
     *
     * Generated from protobuf field <code>string project = 227560217 [(.google.api.field_behavior) = REQUIRED, (.google.cloud.operation_request_field) = "project"];</code>
     * @param string $var
     * @return $this
     */
    public function setProject($var)
    {
        GPBUtil::checkString($var, True);
        $this->project = $var;

        return $this;
    }

    /**
     * Name of the region scoping this request.
     *
     * Generated from protobuf field <code>string region = 138946292 [(.google.api.field_behavior) = REQUIRED, (.google.cloud.operation_request_field) = "region"];</code>
     * @return string
     */
    public function getRegion()
    {
        return $this->region;
    }

    /**
     * Name of the region scoping this request.
     *
     * Generated from protobuf field <code>string region = 138946292 [(.google.api.field_behavior) = REQUIRED, (.google.cloud.operation_request_field) = "region"];</code>
     * @param string $var
     * @return $this
     */
    public function setRegion($var)
    {
        GPBUtil::checkString($var, True);
        $this->region = $var;

        return $this;
    }

    /**
     * An optional request ID to identify requests. Specify a unique request ID so that if you must retry your request, the server will know to ignore the request if it has already been completed. For example, consider a situation where you make an initial request and the request times out. If you make the request again with the same request ID, the server can check if original operation with the same request ID was received, and if so, will ignore the second request. This prevents clients from accidentally creating duplicate commitments. The request ID must be a valid UUID with the exception that zero UUID is not supported ( 00000000-0000-0000-0000-000000000000).
     *
     * Generated from protobuf field <code>optional string request_id = 37109963;</code>
     * @return string
     */
    public function getRequestId()
    {
        return isset($this->request_id) ? $this->request_id : '';
    }

    public function hasRequestId()
    {
        return isset($this->request_id);
    }

    public function clearRequestId()
    {
        unset($this->request_id);
    }

    /**
     * An optional request ID to identify requests. Specify a unique request ID so that if you must retry your request, the server will know to ignore the request if it has already been completed. For example, consider a situation where you make an initial request and the request times out. If you make the request again with the same request ID, the server can check if original operation with the same request ID was received, and if so, will ignore the second request. This prevents clients from accidentally creating duplicate commitments. The request ID must be a valid UUID with the exception that zero UUID is not supported ( 00000000-0000-0000-0000-000000000000).
     *
     * Generated from protobuf field <code>optional string request_id = 37109963;</code>
     * @param string $var
     * @return $this
     */
    public function setRequestId($var)
    {
        GPBUtil::checkString($var, True);
        $this->request_id = $var;

        return $this;
    }

    /**
     * Name of the TargetPool resource to set a backup pool for.
     *
     * Generated from protobuf field <code>string target_pool = 62796298 [(.google.api.field_behavior) = REQUIRED];</code>
     * @return string
     */
    public function getTargetPool()
    {
        return $this->target_pool;
    }

    /**
     * Name of the TargetPool resource to set a backup pool for.
     *
     * Generated from protobuf field <code>string target_pool = 62796298 [(.google.api.field_behavior) = REQUIRED];</code>
     * @param string $var
     * @return $this
     */
    public function setTargetPool($var)
    {
        GPBUtil::checkString($var, True);
        $this->target_pool = $var;

        return $this;
    }

    /**
     * The body resource for this request
     *
     * Generated from protobuf field <code>.google.cloud.compute.v1.TargetReference target_reference_resource = 523721712 [(.google.api.field_behavior) = REQUIRED];</code>
     * @return \Google\Cloud\Compute\V1\TargetReference|null
     */
    public function getTargetReferenceResource()
    {
        return $this->target_reference_resource;
    }

    public function hasTargetReferenceResource()
    {
        return isset($this->target_reference_resource);
    }

    public function clearTargetReferenceResource()
    {
        unset($this->target_reference_resource);
    }

    /**
     * The body resource for this request
     *
     * Generated from protobuf field <code>.google.cloud.compute.v1.TargetReference target_reference_resource = 523721712 [(.google.api.field_behavior) = REQUIRED];</code>
     * @param \Google\Cloud\Compute\V1\TargetReference $var
     * @return $this
     */
    public function setTargetReferenceResource($var)
    {
        GPBUtil::checkMessage($var, \Google\Cloud\Compute\V1\TargetReference::class);
        $this->target_reference_resource = $var;

        return $this;
    }

}
