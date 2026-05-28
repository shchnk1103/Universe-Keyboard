// swift-format-ignore-file
import Foundation

public extension RimeConfigTemplates {
    static let openccT2S = """
        {
          "name": "Traditional Chinese to Simplified Chinese",
          "segmentation": {
            "type": "mmseg",
            "dict": {
              "type": "ocd2",
              "file": "TSPhrases.ocd2"
            }
          },
          "conversion_chain": [{
            "dict": {
              "type": "ocd2",
              "file": "TSCharacters.ocd2"
            }
          }]
        }
        """

    static let openccS2T = """
        {
          "name": "Simplified Chinese to Traditional Chinese",
          "segmentation": {
            "type": "mmseg",
            "dict": {
              "type": "ocd2",
              "file": "STPhrases.ocd2"
            }
          },
          "conversion_chain": [{
            "dict": {
              "type": "ocd2",
              "file": "STCharacters.ocd2"
            }
          }]
        }
        """
}
