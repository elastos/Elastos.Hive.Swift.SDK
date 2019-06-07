

import Foundation

enum HIVE_SUB_Url: String {
    case IPFS_UID_NEW = "uid/new"
    case IPFS_UID_INFO = "uid/info"
    case IPFS_UID_LOGIN = "uid/login"
    case IPFS_FILES_CP = "files/cp"
    case IPFS_FILES_FLUSH = "files/flush"
    case IPFS_FILES_LS = "files/ls"
    case IPFS_FILES_MKDIR = "files/mkdir"
    case IPFS_FILES_MV = "files/mv"
    case IPFS_FILES_READ = "files/read"
    case IPFS_FILES_RM = "files/rm"
    case IPFS_FILES_STAT = "files/stat"
    case IPFS_FILES_WRITE = "files/write"
    case IPFS_NAME_PUBLISH = "name/publish"
}

let KEYCHAIN_IPFS_UID  = "uid"

class HiveIpfsURL {
    internal static let IPFS_NODE_API_BASE = "http://52.83.159.189:9095/api/v0/"
    internal static let IPFS_NODE_API_VRESION = "http://52.83.159.189:9095/version"
}
