// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_perplexity_sonar/otel_perplexity_sonar.dart';

/// Traces Perplexity Sonar Search / Deep Research calls with OpenTelemetry.
///
/// `otel_perplexity_sonar` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Perplexity Sonar Search / Deep Research call in
/// [tracedPerplexitySonar]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'perplexity-sonar-example');

  // Wraps a Perplexity Sonar Search / Deep Research API call in a CLIENT span.
  final perplexitySonarId = await tracedPerplexitySonar<String>(
    operation: 'deep_research.async.create',
    invoke: () async {
      // Make the Perplexity Sonar Search / Deep Research call here, then report what it returned.
      const id = 'perplexity_sonar_8f3a2c';
      return const PerplexitySonarCallResult(
          value: id,
          result: PerplexitySonarResult(
              requestId: 'request_8f3a2c',
              researchJobId: 'researchjob_8f3a2c',
              searchMode: 'web',
              recencyFilter: 'hour',
              domainsAllowed: 'example',
              domainsBlocked: 'example',
              resultsReturned: 1,
              sourcesCount: 3,
              numSearchQueries: 120,
              numReasoningSteps: 1,
              researchStatus: 'queued',
              creditsUsed: 1,
              queryTokens: 128,
              contextTokens: 128,
              outputTokens: 128,
              statusCode: 201));
    },
  );
  OTelLog.info(
      'tracedPerplexitySonar deep_research.async.create returned $perplexitySonarId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutPerplexitySonarInstrumentationAsync.
  await runWithoutPerplexitySonarInstrumentationAsync(
    () => tracedPerplexitySonar<String>(
      operation: 'deep_research.async.create',
      invoke: () async {
        const id = 'perplexity_sonar_8f3a2c';
        return const PerplexitySonarCallResult(
            value: id,
            result: PerplexitySonarResult(
                requestId: 'request_8f3a2c',
                researchJobId: 'researchjob_8f3a2c',
                searchMode: 'web',
                recencyFilter: 'hour',
                domainsAllowed: 'example',
                domainsBlocked: 'example',
                resultsReturned: 1,
                sourcesCount: 3,
                numSearchQueries: 120,
                numReasoningSteps: 1,
                researchStatus: 'queued',
                creditsUsed: 1,
                queryTokens: 128,
                contextTokens: 128,
                outputTokens: 128,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
