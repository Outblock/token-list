import "TokenList"
import "MetadataViews"

access(all)
fun main(
    _ addr: Address
): Status {
    let acct = getAuthAccount(addr)
    let registry = TokenList.borrowRegistry()
    let registryAddr = registry.owner?.address ?? panic("Failed to get registry address")

    let isReviewer = TokenList.borrowReviewerPublic(addr) != nil

    let maintainerId = TokenList.generateReviewMaintainerCapabilityId(addr)
    let reviewers = registry.getReviewers()
    var reviewerAddr: Address? = nil
    var isPendingToClaimReviewMaintainer = false
    for one in reviewers {
        let cap = acct.inbox
            .claim<&TokenList.FungibleTokenReviewer{TokenList.FungibleTokenReviewMaintainer, TokenList.FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}>(
                maintainerId,
                provider: one
            )
        if cap != nil {
            reviewerAddr = one
            isPendingToClaimReviewMaintainer = true
            break
        }
    }

    let isReviewMaintainer = acct.check<&TokenList.ReviewMaintainer>(from: TokenList.maintainerStoragePath)
    if isReviewMaintainer {
        let maintainer = acct.borrow<&TokenList.ReviewMaintainer>(from: TokenList.maintainerStoragePath)
        reviewerAddr = maintainer?.getReviewerAddress()
    }

    return Status(
        isReviewer,
        isReviewMaintainer,
        isPendingToClaimReviewMaintainer,
        isReviewer
            ? addr
            : reviewerAddr,
    )
}

access(all) struct Status {
    access(all)
    let isReviewer: Bool
    access(all)
    let isReviewMaintainer: Bool
    access(all)
    let isPendingToClaimReviewMaintainer: Bool
    access(all)
    let reviewerAddr: Address?

    init(
        _ isReviewer: Bool,
        _ isReviewMaintainer: Bool,
        _ isPendingToClaimReviewMaintainer: Bool,
        _ reviewerAddr: Address?,
    ) {
        self.isReviewer = isReviewer
        self.reviewerAddr = reviewerAddr
        self.isReviewMaintainer = isReviewMaintainer
        self.isPendingToClaimReviewMaintainer = isPendingToClaimReviewMaintainer
    }
}
