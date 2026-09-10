    # Weekly Progress Log

## Week 1

**Tasks Completed:**
- Phase 0: Initialized Flutter project, set up folder structure, theme constants, and README
- Phase 1: Built Home Screen and All Tools Screen with searchable tool grid
- Phase 2: Built Tool Detail Screen and integrated file_picker for file selection
- Phase 3: Implemented CloudConvertService (job creation, file upload, polling, download) and ConversionModel
- Phase 4: Added local JPG ↔ PNG conversion using the image package (no API needed)
- Phase 5: Built Converting Screen with animated progress and Result Screen with open/share actions
- Phase 6: Built History Screen and Settings Screen with dark/light mode toggle, added StorageService using shared_preferences

**Challenges:**
- Handling asynchronous job polling from CloudConvert without blocking the UI
- Structuring ConversionModel so it could serve both CloudConvert jobs and local conversions with one shared model
- Making sure the Result Screen didn't break before StorageService existed (dependency ordering across phases)

**Plan for Next Week:**
- Complete Phase 7: permission handling and file validation (type/size checks)
- Test the full conversion flow end-to-end on a real device
- Capture screenshots for the screenshots/ folder
- Finalize and polish README.md

---

## Week 2

**Tasks Completed:**
- Phase 7: Added PermissionService for storage/photos access and FileUploadArea widget with file type and size validation
- Ran full end-to-end testing across all 12 conversion tools
- Captured and committed screenshots
- Finalized README.md with project description, features, and setup instructions

**Challenges:**
- Initial testing on Chrome web surfaced CORS restrictions blocking the CloudConvert file upload step, since browsers block cross-origin requests to the S3 pre-signed upload URL
- Diagnosed that the project's default Chrome launch flags (via IDE run button) were overriding the custom `--disable-web-security` flag intended for local testing

**Plan for Next Week:**
- Switch primary testing target from Chrome web to a physical Android device to avoid browser CORS limitations entirely
- Resolve Android build toolchain issues (Kotlin/Gradle version compatibility) blocking a successful Android build
- Continue debugging the file conversion pipeline until all 12 tools complete successfully end-to-end

---

## Week 3 (Final Week)

**Tasks Completed:**
- Set up and debugged Android build toolchain: resolved disk space, Kotlin Gradle Plugin version mismatch (upgraded to 2.1.0), Windows Defender file-lock conflicts, and an outdated file_picker dependency (upgraded 6.1.1 → 8.1.2)
- Successfully built and installed the app on a physical Android device, bypassing web CORS limitations entirely
- Added the missing INTERNET permission and additional storage/media permissions to AndroidManifest.xml
- Identified and fixed a core bug in CloudConvertService: the file upload step was missing required S3 pre-signed POST form fields (key, policy, signature), causing every conversion to fail at the upload stage regardless of tool. Added the missing fields and improved error logging via debugPrint
- Diagnosed a secondary conversion-pipeline issue occurring at the export/download stage using ADB logcat output, after the Flutter debug console intermittently failed to attach to the physical device
- Confirmed all 7 development phases complete — 19 dart files across screens, models, services, and widgets, plus AndroidManifest, README, and .gitignore finalized
- Updated app label to "ConvertIT" in AndroidManifest.xml and prepared the custom app icon setup via flutter_launcher_icons
- Reviewed GitHub activity strategy against grading criteria (Consistency, Meaningful Progress, Git Hygiene, Timeliness, Repo Professionalism) to plan remaining commits

**Challenges:**
- Multiple sequential Android build environment issues required systematic diagnosis (disk space, toolchain versions, file locks, dependency compatibility) before the app could run natively at all
- The generic error messaging in the original CloudConvertService masked the true root cause of the upload failures; required direct code review and added logging to identify the actual issue
- Flutter's debug console occasionally failed to attach to the physical device's VM service, requiring ADB logcat as a fallback method to capture runtime logs

