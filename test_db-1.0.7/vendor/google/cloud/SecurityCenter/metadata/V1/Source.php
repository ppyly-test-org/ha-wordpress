<?php
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: google/cloud/securitycenter/v1/source.proto

namespace GPBMetadata\Google\Cloud\Securitycenter\V1;

class Source
{
    public static $is_initialized = false;

    public static function initOnce() {
        $pool = \Google\Protobuf\Internal\DescriptorPool::getGeneratedPool();

        if (static::$is_initialized == true) {
          return;
        }
        \GPBMetadata\Google\Api\Resource::initOnce();
        $pool->internalAddGeneratedFile(
            '
�
+google/cloud/securitycenter/v1/source.protogoogle.cloud.securitycenter.v1"�
Source
name (	
display_name (	
description (	
canonical_name (	:��A�
$securitycenter.googleapis.com/Source-organizations/{organization}/sources/{source}!folders/{folder}/sources/{source}#projects/{project}/sources/{source}B�
"com.google.cloud.securitycenter.v1PZLgoogle.golang.org/genproto/googleapis/cloud/securitycenter/v1;securitycenter�Google.Cloud.SecurityCenter.V1�Google\\Cloud\\SecurityCenter\\V1�!Google::Cloud::SecurityCenter::V1bproto3'
        , true);

        static::$is_initialized = true;
    }
}
