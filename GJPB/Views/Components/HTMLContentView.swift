//
//  HTMLContentView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI
import WebKit

struct HTMLContentView: UIViewRepresentable {
    let htmlContent: String
    let isDarkMode: Bool
    let accentColor: String
    @Binding var contentHeight: CGFloat

    init(
        htmlContent: String,
        isDarkMode: Bool,
        accentColor: String = "#3b82f6",
        contentHeight: Binding<CGFloat> = .constant(400)
    ) {
        self.htmlContent = htmlContent
        self.isDarkMode = isDarkMode
        self.accentColor = accentColor
        self._contentHeight = contentHeight
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let fullHTML = wrapHTML(htmlContent)
        webView.loadHTMLString(fullHTML, baseURL: nil)
    }

    // MARK: - HTML Wrapper with theme-aware CSS
    private func wrapHTML(_ body: String) -> String {
        let bgColor = isDarkMode ? "#1c1c1e" : "#ffffff"
        let textColor = isDarkMode ? "#f2f2f7" : "#1c1c1e"
        let codeBg = isDarkMode ? "#2c2c2e" : "#f5f5f5"
        let borderColor = isDarkMode ? "#3a3a3c" : "#e5e5e5"
        let hlTheme = isDarkMode ? "atom-one-dark" : "atom-one-light"

        // Process YouTube embeds: <div class="video-embed" data-provider="youtube" src="URL">
        let processedBody = body.replacingOccurrences(
            of: #"<div\s+class="video-embed"\s+data-provider="youtube"\s+src="([^"]+)"[^>]*>.*?</div>"#,
            with: #"<div class="video-container"><iframe src="$1" frameborder="0" allowfullscreen style="width:100%;aspect-ratio:16/9;border-radius:8px;"></iframe></div>"#,
            options: .regularExpression
        )

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/\(hlTheme).min.css">
            <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
            <style>
                * { box-sizing: border-box; margin: 0; padding: 0; }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', sans-serif;
                    font-size: 16px;
                    line-height: 1.75;
                    color: \(textColor);
                    background-color: \(bgColor);
                    padding: 0 4px;
                    word-wrap: break-word;
                    -webkit-text-size-adjust: 100%;
                }
                p { margin: 12px 0; }
                img { max-width: 100%; height: auto; border-radius: 8px; margin: 8px 0; }
                pre {
                    background: \(codeBg);
                    border: 1px solid \(borderColor);
                    border-radius: 8px;
                    padding: 16px;
                    overflow-x: auto;
                    position: relative;
                    margin: 12px 0;
                }
                code {
                    font-family: 'SF Mono', Menlo, Monaco, monospace;
                    font-size: 13px;
                }
                :not(pre) > code {
                    background: \(codeBg);
                    padding: 2px 6px;
                    border-radius: 4px;
                    font-size: 14px;
                }
                .copy-btn {
                    position: absolute;
                    top: 8px;
                    right: 8px;
                    background: \(isDarkMode ? "#555" : "#ddd");
                    border: none;
                    border-radius: 4px;
                    padding: 4px 10px;
                    cursor: pointer;
                    font-size: 12px;
                    color: \(textColor);
                }
                table {
                    width: 100%;
                    border-collapse: collapse;
                    margin: 16px 0;
                    overflow-x: auto;
                    display: block;
                }
                th, td {
                    border: 1px solid \(borderColor);
                    padding: 8px 12px;
                    text-align: left;
                }
                th { background: \(codeBg); font-weight: 600; }
                a { color: \(accentColor); text-decoration: none; }
                a:hover { text-decoration: underline; }
                h1 { font-size: 24px; margin: 24px 0 12px; }
                h2 { font-size: 20px; margin: 20px 0 10px; }
                h3 { font-size: 18px; margin: 18px 0 8px; }
                h4 { font-size: 16px; margin: 16px 0 8px; }
                blockquote {
                    border-left: 4px solid \(accentColor);
                    margin: 16px 0;
                    padding: 8px 16px;
                    background: \(codeBg);
                    border-radius: 0 8px 8px 0;
                }
                ul, ol { padding-left: 24px; margin: 12px 0; }
                li { margin: 4px 0; }
                hr { border: none; border-top: 1px solid \(borderColor); margin: 24px 0; }
                .video-container {
                    position: relative;
                    width: 100%;
                    margin: 16px 0;
                }
                .video-container iframe {
                    width: 100%;
                    aspect-ratio: 16/9;
                    border-radius: 8px;
                    border: none;
                }
            </style>
        </head>
        <body>
            \(processedBody)
            <script>
                hljs.highlightAll();
                document.querySelectorAll('pre').forEach(function(pre) {
                    var btn = document.createElement('button');
                    btn.className = 'copy-btn';
                    btn.textContent = 'Copy';
                    btn.onclick = function() {
                        var code = pre.querySelector('code') || pre;
                        var text = code.textContent;
                        if (navigator.clipboard) {
                            navigator.clipboard.writeText(text).then(function() {
                                btn.textContent = 'Copied!';
                                setTimeout(function() { btn.textContent = 'Copy'; }, 2000);
                            });
                        }
                    };
                    pre.appendChild(btn);
                });
            </script>
        </body>
        </html>
        """
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HTMLContentView

        init(_ parent: HTMLContentView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.body.scrollHeight") { [weak self] result, _ in
                if let height = result as? CGFloat, height > 0 {
                    Task { @MainActor in
                        self?.parent.contentHeight = height
                    }
                }
            }
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}
