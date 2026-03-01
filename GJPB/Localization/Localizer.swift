//
//  Localizer.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import Foundation

struct Localizer {
    static func text(_ key: String, lang: String) -> String {
        translations[key]?[lang] ?? translations[key]?["EN"] ?? key
    }

    // MARK: - Translation Dictionary
    private static let translations: [String: [String: String]] = [
        // General
        "loading":              ["EN": "Loading...",               "ZH": "加载中..."],
        "failed_to_load":       ["EN": "Failed to load data",     "ZH": "加载失败"],
        "retry":                ["EN": "Retry",                    "ZH": "重试"],
        "search.placeholder":   ["EN": "Search...",               "ZH": "搜索..."],
        "filter.all":           ["EN": "All",                      "ZH": "全部"],

        // Theme & Language toggles
        "toggle.theme.light":          ["EN": "Switch to light mode",  "ZH": "切换到浅色模式"],
        "toggle.theme.dark":           ["EN": "Switch to dark mode",   "ZH": "切换到深色模式"],
        "toggle.language.toChinese":   ["EN": "切换到中文",              "ZH": "Switch to English"],

        // Not found
        "notfound.title":    ["EN": "Page Not Found",                            "ZH": "页面未找到"],
        "notfound.subtitle": ["EN": "The page you're looking for doesn't exist", "ZH": "您访问的页面不存在"],

        // Websites
        "websites.title": ["EN": "Websites",          "ZH": "网站"],
        "websites.empty": ["EN": "No websites found",  "ZH": "未找到网站"],

        // Q&A
        "questions.title": ["EN": "Q&A",                 "ZH": "问答"],
        "questions.empty": ["EN": "No questions found",   "ZH": "未找到问题"],

        // Articles
        "articles.title":         ["EN": "Articles",              "ZH": "文章"],
        "articles.empty":         ["EN": "No articles found",     "ZH": "未找到文章"],
        "articles.back_to_list":  ["EN": "Back to Articles",      "ZH": "返回文章列表"],
        "articles.view_original": ["EN": "View Original Article", "ZH": "查看原文"],

        // Images
        "images.title": ["EN": "Images",          "ZH": "图片"],
        "images.empty": ["EN": "No images found",  "ZH": "未找到图片"],

        // Audios
        "audios.title": ["EN": "Audios",          "ZH": "音频"],
        "audios.empty": ["EN": "No audios found",  "ZH": "未找到音频"],

        // Videos
        "videos.title":      ["EN": "Videos",      "ZH": "视频"],
        "videos.empty":      ["EN": "No videos found", "ZH": "未找到视频"],
        "videos.play_video": ["EN": "Play Video",  "ZH": "播放视频"],

        // Files
        "files.title":    ["EN": "Files",          "ZH": "文件"],
        "files.empty":    ["EN": "No files found",  "ZH": "未找到文件"],
        "file.download":  ["EN": "Download",        "ZH": "下载"],

        // Sort
        "sort.default": ["EN": "Default Order", "ZH": "默认排序"],
        "sort.alpha":   ["EN": "Alphabetical",  "ZH": "字母排序"],
        "sort.recent":  ["EN": "Most Recent",   "ZH": "最近更新"],

        // Pagination
        "pagination.of":      ["EN": "of",       "ZH": "共"],
        "pagination.perPage": ["EN": "per page",  "ZH": "每页"],

        // More tab
        "more.title": ["EN": "More", "ZH": "更多"],
    ]
}
