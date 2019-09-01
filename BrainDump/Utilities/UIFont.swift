import UIKit

extension UIFont {

    /// Returns `lineSpacing` such that `lineHeight * lineHeightMultiple = lineHeight + lineSpacing`.
    func lineSpacing(matchingLineHeightMultiple multiple: CGFloat) -> CGFloat {
        return lineHeight * multiple - lineHeight
    }

    /// Returns `lineHeightMultiple` such that `lineHeight * lineHeightMultiple = lineHeight + lineSpacing`.
    func lineHeightMultiple(matchingLineSpacing lineSpacing: CGFloat) -> CGFloat {
        return (lineHeight + lineSpacing) / lineHeight
    }

    /// For a given line height multiple returns an adjusted multiple and a line spacing
    /// such that the space from the adjusted multiple and the space from the line spacing
    /// are equal while totaling the space caused by the given initial multiple.
    func adjustedLineHeightMultipleAndSpacing(forPreferredMultiple multiple: CGFloat) -> (multiple: CGFloat, spacing: CGFloat) {
        let spacing = lineSpacing(matchingLineHeightMultiple: multiple) / 2
        let adjustedMultiple = lineHeightMultiple(matchingLineSpacing: spacing)
        return (adjustedMultiple, spacing)
    }
}
