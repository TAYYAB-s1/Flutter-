# Project Proposal

## Student Information

Name: Muhammad Tayyab

Registration Number: F2024376199

## Project Title

ConvertIt — Mobile File Converter App

## Problem Statement

Students and professionals frequently need to convert files between formats (PDF ↔ Word, PDF ↔ Image, Excel ↔ PDF, etc.) but existing tools are either desktop-only, cluttered with ads, or require opening a browser and uploading files to unfamiliar websites. There is no clean, fast, mobile-first file converter that works entirely from a smartphone. ConvertIt solves this by bringing 12 common file conversion tools into a single, easy-to-use Flutter mobile app — no browser, no ads, no friction.

## Target Users

- Students who need to convert assignment files between PDF and Word formats
- Office workers who frequently deal with PDF, Excel, and PowerPoint files on the go
- General smartphone users who want a simple, one-tap solution for file conversion without visiting websites

## Main Features

1. Tool grid with 12 file conversion tools (PDF, Word, Excel, PowerPoint, Image formats), including live search and category filters
2. File picker integration with type and size validation before conversion
3. Real-time animated conversion progress screen (Upload → Convert → Export → Done)
4. Result screen with download, open, and share options for converted files
5. Conversion history with re-download, delete, and search, plus full dark/light mode support

## External APIs (if any)

CloudConvert REST API v2 (https://api.cloudconvert.com/v2) — handles server-side conversions for PDF, Word, Excel, and PowerPoint formats (free tier: 25 conversions/day). JPG ↔ PNG conversions are handled entirely on-device using the Dart `image` package, with no API call required.