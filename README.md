# 🔎 Browser Performance Troubleshooting Mini-Lab  
**Chrome vs Edge – Evidence-Based PowerShell Analysis**

---

## 📌 Project Overview

This project investigates performance differences between Google Chrome and Microsoft Edge during extended ChatGPT sessions.

Rather than relying on perception, I captured objective system and process metrics using PowerShell, aggregated totals per browser, and exported timestamped artifacts for reproducible analysis.

---

## 🎯 Objective

- Compare CPU usage and memory consumption between Chrome and Edge
- Use structured PowerShell measurement
- Export timestamped evidence artifacts
- Document findings in a professional format

---

## 🖥️ System Baseline

Captured using:

```powershell
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber, CsTotalPhysicalMemory


System:

Windows 10 Home

Build 26200

~31.7 GB usable RAM


Measured Results (Script Execution)
| Metric          | Microsoft Edge | Google Chrome |
| --------------- | -------------- | ------------- |
| Process Count   | 11             | 11            |
| Total CPU Time  | 384.56         | 61.95         |
| Total RAM Usage | 2152.77 MB     | 801.74 MB     |
| RAM % of System | ~6.79%         | ~2.53%        |

Key Insight

Edge consumed significantly more CPU and RAM during the same session, yet delivered smoother perceived responsiveness.

This demonstrates that responsiveness is influenced by:

Rendering efficiency

Process scheduling

OS-level optimization

Multi-process architecture behavior


Reusable Script

This project includes a PowerShell script that:

Captures system baseline

Collects per-process RAM + CPU usage

Aggregates totals by browser

Calculates RAM % of system

Exports TXT + CSV artifacts

Handles OneDrive Desktop redirection automatically

Core Principle

Measure first. Analyze second. Conclude last.

👤 Author

Tomasz J. Lyszyk
CompTIA A+ | Pursuing Security+
Structured troubleshooting & lab documentation focus

