//Created on 10/31/19, for ZielStk, by Roman Voinitchi
//Copyright © 2019 Roman Voinitchi. All rights reserved.
    

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let attachments = item.attachments {
                for attachment in attachments {
                    if attachment.hasItemConformingToTypeIdentifier("public.plain-text") {
                        attachment.loadItem(forTypeIdentifier: "public.plain-text", options: nil, completionHandler: { (item, error) in
                            if let postedText = item as? String {
                                let ud = UserDefaults(suiteName: "group.com.CTestGroup")
                                ud?.setValue(postedText, forKey: "keyPostedString")
                                ud?.synchronize()
                            }
                        })
                    }
                }
            }
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        return []
    }

}
