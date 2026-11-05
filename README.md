# TrustScore

**Trust Beyond Credit History. Expanding Access Through Responsible AI.**

TrustScore is a proposed AI-powered financial inclusion platform. It provides participating financial institutions with supplementary, explainable financial-behaviour assessments while ensuring that applicants without sufficient evidence are not automatically treated as unreliable.

The project now includes an **offline Flutter demonstration frontend**. It has no production integrations, real National ID checks, real financial records, or validated real-world predictive claims. The app uses synthetic applicants, bundled CSV records, simulated identity/data states, and a clearly labelled mock assessment service.

## Core principles

- TrustScore is an additional 0–1,000 assessment, not a loan decision or guarantee.
- The provisional 750 benchmark is a hypothesis for demonstration only; it is not a validated approval threshold.
- Missing data is not negative data.
- Applicants follow either a TrustScore pathway or an alternative/assisted-access pathway.
- Financial institutions retain responsibility for affordability, lending, and compliance decisions.
- Privacy, consent, explainability, fairness, and human oversight are first-class requirements.

## Documentation

- [Project overview](docs/PROJECT_OVERVIEW.md)
- [Technical architecture](docs/TECHNICAL_ARCHITECTURE.md)
- [Development roadmap](docs/DEVELOPMENT_ROADMAP.md)
- [AI/ML specification](docs/AI_ML_SPECIFICATION.md)
- [Database schema](docs/DATABASE_SCHEMA.md)
- [Security and privacy](docs/SECURITY_AND_PRIVACY.md)
- [Feature specification](docs/FEATURE_SPECIFICATION.md)
- [Decisions and assumptions](docs/DECISIONS_AND_ASSUMPTIONS.md)
- [Agent instructions](docs/AGENT_INSTRUCTIONS.md)
- [Initial repository inspection](docs/REPOSITORY_INSPECTION.md)

## Flutter demonstration

The Flutter app lives in [`lib/`](lib/) and uses three bundled datasets in [`assets/data/`](assets/data/). It provides:

- Judge Demo Mode with reset and one-tap applicant switching;
- applicant journey states for simulated verification, consent, evidence and assessment;
- TrustScore and alternative-assessment pathways;
- institution review, interest assistance, application status messaging, and settings;
- explicit synthetic, simulated, supplementary, and AI-pending disclosures.

Run it from a machine with Flutter installed:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

The current environment used to scaffold this project does not have the Flutter/Dart SDK installed, so those commands still need to be run in a Flutter-enabled environment.

## Planned backend and model work

The first implementation should demonstrate applicant registration, simulated identity verification, explicit consent, both assessment pathways, synthetic financial indicators, an illustrative TrustScore with explanations, insufficient-evidence handling, an institution dashboard, and a separate interest-assistance demonstration.

The mobile frontend intentionally does not implement the AI model, live providers, automatic lending decisions, or real assistance funding. Those remain future phases described in the documentation.
