# TrustScore

**Trust Beyond Credit History. Expanding Access Through Responsible AI.**

TrustScore is a proposed AI-powered financial inclusion platform. It provides participating financial institutions with supplementary, explainable financial-behaviour assessments while ensuring that applicants without sufficient evidence are not automatically treated as unreliable.

The project now includes a Flutter demonstration frontend. It has no production integrations, real National ID checks, real financial records, or validated real-world predictive claims. The app uses synthetic applicants, a bundled CSV, Ollama scoring, and simulated identity/data states.

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

The Flutter app lives in [`lib/`](lib/) and loads every row in [`assets/data/applicants.csv`](assets/data/applicants.csv) as a profile. It provides:

- Judge Demo Mode with reset and one-tap applicant switching;
- applicant journey states for simulated verification, consent, evidence and assessment;
- TrustScore and alternative-assessment pathways;
- institution review, interest assistance, application status messaging, and settings;
- explicit synthetic, simulated, and supplementary disclosures;
- TrustScore scoring through Ollama on the operator's laptop, using numeric
  evidence, an optional plain-English profile description, or both;
- local persistence of each Ollama result against a hash of the profile inputs.

Run it from a machine with Flutter installed:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Scoring with Ollama on your laptop

The assessment screen sends the six optional numeric evidence fields and the
optional plain-English description to an Ollama server. The description alone
can support a score when it contains relevant information. Each uncached
profile is scored three times and the average is stored locally. If Ollama is
unavailable, no local model is used.

1. Install [Ollama](https://ollama.com) on the laptop and pull a model:

   ```bash
   ollama pull llama3.2
   ```

2. Start it on an address the phone or emulator can reach:

   ```bash
   OLLAMA_HOST=0.0.0.0 ollama serve
   ```

3. Open **Settings → TrustScore model** in the app and set the base URL:

   - Android emulator: `http://10.0.2.2:11434`
   - Phone on the same Wi-Fi: `http://<laptop-LAN-IP>:11434`
   - Same machine (desktop build): `http://127.0.0.1:11434`

   Then set the model name (for example `llama3.2`) and tap **Test connection**.
   The app lists the models installed on the laptop and runs a probe score.
   Tap an installed model to use it — the model in the field must be installed,
   otherwise `/api/chat` cannot score.

The same values can be baked in at build time:

```bash
flutter run \
  --dart-define=OLLAMA_BASE_URL=http://192.168.1.20:11434 \
  --dart-define=OLLAMA_MODEL=llama3.2
```

Use `--dart-define=OLLAMA_ENABLED=false` to disable scoring. Saved scores are
reused when profile inputs have not changed. Newly created or edited profiles
are scored through Ollama, and the card footer shows the Ollama model version.

To add profiles, edit `assets/data/applicants.csv` and add one row per person using the existing header. Rebuild the app after changing the bundled asset; there is no fixed profile limit beyond device memory.

## Planned backend and model work

The first implementation should demonstrate applicant registration, simulated identity verification, explicit consent, both assessment pathways, synthetic financial indicators, an illustrative TrustScore with explanations, insufficient-evidence handling, an institution dashboard, and a separate interest-assistance demonstration.

The mobile frontend does not implement live providers, automatic lending decisions, or real assistance funding. Those remain future phases described in the documentation.
