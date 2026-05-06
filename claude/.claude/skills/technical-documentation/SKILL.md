---
name: technical-documentation
disable-model-invocation: true
description: "Create and evaluate documentation using the Diátaxis framework. Use when writing, organizing, or auditing documentation to ensure it serves distinct user needs through four systematic categories (Tutorials, How-to Guides, Reference, Explanation). Ideal for diagnosing documentation problems, separating mixed content, and ensuring each piece serves a single, clear purpose."
---
 
Diátaxis Documentation Skill
The Diátaxis framework organizes documentation by user need, not by topic. This skill helps you create documentation that works for your audience.
 
The Four Categories
Diátaxis distinguishes four documentation needs using a 2×2 matrix:
 
Practical	Theoretical
Learning	Tutorials	Explanation
Working	How-to Guides	Reference
Quick Reference
Tutorials (Learning + Practical): "Teach me by doing"
How-to Guides (Working + Practical): "Help me accomplish X"
Reference (Working + Theoretical): "Tell me how things work"
Explanation (Learning + Theoretical): "Help me understand why"
Working With Documentation
1. Diagnose What You Have
When given documentation, determine which category it belongs to:
Is it teaching or working? (Axis 1)
Is it practical or theoretical? (Axis 2)
Does it serve a single purpose or is it mixed?
2. Identify Problems
Common documentation problems map to mixing categories:
 
Tutorials polluted with explanation → Users get lost in "why" when they should focus on "do"
How-to guides that teach → Assumes no prior knowledge; should link to tutorials instead
Reference missing examples → Should show, not just describe
Explanation that instructs → Should link to how-to guides instead
Missing entire categories → Product has only reference; users can't get started
3. Choose the Right Template
When writing documentation, use the appropriate template:
 
Writing a tutorial? See tutorial-template.md
Writing a how-to guide? See how-to-guide-template.md
Writing reference? See reference-template.md
Writing explanation? See explanation-template.md
Want real-world examples? See examples.md
4. Apply Category-Specific Principles
See framework.md for detailed principles, language patterns, and anti-patterns for each category.
 
5. Structure Output
Create documentation in this structure:
.docs/
├── tutorials/          # Learning-oriented lessons
│   └── [topic]/
├── how-to/             # Task-oriented guides
│   └── [domain]/
├── reference/          # Technical descriptions
│   └── [component]/
├── explanation/        # Conceptual discussions
│   └── [subject]/
└── index.md            # Navigation (generated automatically)
Naming conventions:
 
Use kebab-case for all files and folders
Tutorials: getting-started-with-x.md, your-first-y.md
How-to: how-to-configure-x.md, how-to-deploy-y.md
Reference: api-reference.md, configuration-options.md
Explanation: about-architecture.md, understanding-x.md
6. Generate Index
Use the Python script to automatically generate the index.md file:
 
python skills/diataxis/scripts/generate_index.py
This script scans the .docs/ subfolders, extracts titles from .md files, and creates links organized by category. Run it whenever you add or remove documentation files to keep the index up-to-date.
 
Common Workflows
Auditing existing documentation
Read through each document
Determine which category it belongs to
Flag content that belongs in other categories
Suggest extractions or links to separate content
Check for "category pollution" (mixing purposes)
Writing new documentation
Identify the user need (learning/working, practical/theoretical)
Choose the appropriate category
Find the right template:
Tutorial: tutorial-template.md
How-to: how-to-guide-template.md
Reference: reference-template.md
Explanation: explanation-template.md
Use category-specific language patterns (in template)
See examples.md for production-grade examples
Save in the correct folder structure
Refactoring mixed content
Read the mixed document
Identify sections that belong in different categories
Create separate files for each category
In each file, link to related content in other categories
Remove the original mixed document
Generating the documentation index
To keep the documentation index consistent and up-to-date:
 
Ensure all documentation files are placed in the appropriate .docs/ subfolders (tutorials/, how-to/, reference/, explanation/).
Run the generation script: python skills/diataxis/scripts/generate_index.py
The script will automatically scan for .md files, extract their titles, and update .docs/index.md with organized links.
This workflow should be used after adding new documents or restructuring existing ones.
 
Key Principle
Every document should serve exactly one user need. When content serves multiple needs, separate it into multiple documents and link them together. This is better than trying to serve all needs in one place.
 
Remember: The first rule of teaching is simply: don't try to teach. Let the structure and the doing facilitate learning.
