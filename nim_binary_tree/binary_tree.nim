##A nim binary tree implementation with auto-balancing
import hashes

type
    Node*[T, K] = ref object of RootObj
        key: T
        value: K
        left, right: Node[T, K]

    BinaryTree*[T, K] = ref object of RootObj
        rootNode: Node[T, K]

proc newNode*[T, K](key: T, value: K): Node[T, K] =
    new(result)
    result.key = key
    result.value = value

proc insertNode[T, K](root: var Node[T, K], key: T, value: K) {.discardable.} =
    if isNil(root):
        root = newNode(key, value)
    elif key < root.left.key:
        root.left = insertNode(root.left, key, value)
    else:
        root.right = insertNode(root.right, key, value)

proc search[T, K](root: Node[T, K], key: T): Node[T, K] =
    if isNil(root) or root.key == key:
        return root
    if key < root.key:
        return search(root.left, key)

    return search(root.right, key)

proc insertNode*[T, K](tree: var BinaryTree[T, K], key: T, value: K) {.discardable.} =
    discard tree.rootNode.insertNode(key, value)

proc search*[T, K](tree: BinaryTree[T, K], key: K): Node[T, K] =
    return tree.root.search(key)
