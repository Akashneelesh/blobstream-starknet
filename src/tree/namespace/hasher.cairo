use alexandria_bytes::BytesTrait;
use blobstream_sn::utils::encode_packed;
use blobstream_sn::tree::namespace::merkle_tree::{
    Namespace, NamespaceNode, NamespaceMerkleMultiproof, NamespaceMerkleProof
};
use alexandria_bytes::bytes::Bytes;
use blobstream_sn::tree::consts::{LEAF_PREFIX, NODE_PREFIX, parity_share_namespace};

// fn leafDigest(namespace : Namespace,data : Bytes) -> NamespaceNode {
//     let mut bytes =  BytesTrait::new(1, array![LEAF_PREFIX]);
//     bytes.append
// }

fn namespace_min(l: Namespace, r: Namespace) -> Namespace {
    if l < r {
        return l;
    }
    return r;
}

fn namespace_max(l: Namespace, r: Namespace) -> Namespace {
    if l > r {
        return l;
    }
    return r;
}

fn leaf_digest(namespace: Namespace, data: u256) -> NamespaceNode {
    let mut bytes = BytesTrait::new(1, array![LEAF_PREFIX]);
    bytes.append_u8(namespace.version);
    append_bytes31(ref bytes, namespace.id);
    if data > 0 {
        bytes.append_u256(data);
    }

    return NamespaceNode { min: namespace, max: namespace, digest: bytes.sha256() };
}

fn node_digest(left: NamespaceNode, right: NamespaceNode) -> NamespaceNode {
    let min: Namespace = namespace_min(left.min, right.min);
    let mut max: Namespace = namespace_max(left.max, right.max);
    if (left.min == parity_share_namespace()) {
        max = parity_share_namespace();
    } else if (right.min == parity_share_namespace()) {
        max = left.max;
    } else {
        max = namespace_max(left.max, right.max);
    }

    let mut bytes = BytesTrait::new(1, array![NODE_PREFIX]);
    bytes.append(left.min);
    bytes.append(left.max);
    bytes.append_u256(left.digest);
    bytes.append(right.min);
    bytes.append(right.max);
    bytes.append_u256(right.digest);

    return NamespaceNode {
        min: namespace_min(left.min, right.min),
        max: namespace_max(left.max, right.max),
        digest: bytes.sha256()
    };
}

fn append_bytes31(ref self: Bytes, value: bytes31) {
    let value_u256: u256 = value.into();
    self.append_u256(value_u256);
}
