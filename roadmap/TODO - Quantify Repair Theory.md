# Quantify Repair Theory

## Objective

Turn Repair Theory from a qualitative classification into a falsifiable comparison of interventions. The first benchmark uses a finite synthetic state space with exact ground truth, so every valid distinction, transition, loss event, and recovery claim is known rather than inferred.

## Operational claim

Let \(X\) be a finite set of states, \(A\) a set of interventions, and \(T:X\times A\to X\cup\{\bot\}\) the ground-truth transition function. Let \(V\subseteq X\) be the valid states and let \(\phi:X\to Y\) return task-relevant observables. A damage operator \(D:X\to Z\) may remove or corrupt information, and a candidate repair \(R:Z\to X\) produces \(\hat x=R(D(x))\).

Two states are meaningfully distinct when their future behavior differs:

\[
x\not\equiv_T x' \iff \exists a_{1:k}\in A^*:\;\phi(T^*(x,a_{1:k}))\neq\phi(T^*(x',a_{1:k})).
\]

A candidate is a repair only to the extent that it restores valid, task-relevant reachability while preserving every distinction that remains identifiable after damage. It is smoothing when it reduces local discrepancy by collapsing distinct cases toward a common state. It is erasure when it obtains apparent success by deleting, masking, abstaining on, or making inaccessible the damaged component without restoring its supported behavior.

No method may be credited with recovering distinctions that the damaged observation does not identify. Define the information class

\[
[x]_D=\{x'\in X:D(x')=D(x)\}.
\]

Exact identity recovery is warranted only when \(|[x]_D|=1\). When \(|[x]_D|>1\), evaluation must report the identifiable common behavior of the class separately from any guessed identity.

## Measurable quantities

For a test distribution over initial states and intervention sequences, record the following quantities for both damaged and repaired states.

**Validity recovery**

\[
V_R=\Pr[\hat x\in V]-\Pr[D(x)\in V],
\]

using an explicit embedding or validity predicate for damaged observations.

**Behavioral recovery**

\[
B_R=1-\mathbb{E}_{x,a_{1:k}}\!\left[d_Y\bigl(\phi(T^*(x,a_{1:k})),\phi(T^*(\hat x,a_{1:k}))\bigr)\right],
\]

with \(d_Y\) normalized to \([0,1]\). Report this by horizon \(k\), not only as one aggregate.

**Distinction retention**

\[
P_R=1-\frac{\sum_{x<x'} w_{xx'}\,\mathbf 1[x\not\equiv_Tx']\,\mathbf 1[\hat x\equiv_T\hat x']}{\sum_{x<x'} w_{xx'}\,\mathbf 1[x\not\equiv_Tx']},
\]

where pair weights and equivalence tolerances are fixed before the run. This directly measures whether repair collapses differences.

**Unsupported reconstruction rate**

\[
U_R=\Pr[\hat x\text{ selects a feature or identity not shared by all members of }[x]_D].
\]

This separates justified repair from plausible fabrication.

**Reachability recovery**

\[
Q_R=1-\mathbb{E}_x\left[\frac{|\mathcal R_H(x)\triangle\mathcal R_H(\hat x)|}{|\mathcal R_H(x)\cup\mathcal R_H(\hat x)|}\right],
\]

where \(\mathcal R_H(x)\) is the set of task-relevant states reachable within horizon \(H\).

**Intervention cost**

Record changed components, edit magnitude, computation, and any irreversible commitments as a cost vector \(C_R\). Do not hide these dimensions in a single score.

Two repairs are therefore compared by the profile

\[
\mathcal P(R)=(V_R,B_R,P_R,Q_R,1-U_R,C_R),
\]

with Pareto dominance reported before any optional weighted ranking. A low reconstruction error alone is not evidence of repair.

## Minimal exact-ground-truth benchmark

Construct a small deterministic transition system with 16–64 states. Each state contains at least two independent latent bits and one redundant or parity feature. Design the transition table so that superficially similar states diverge under at least one intervention. Mark a subset invalid without making all invalid states behaviorally identical.

Apply three damage families at several severities: deletion of one observed component, corruption of one component, and many-to-one aggregation that creates known information classes. Retain the complete undamaged state and transition table only as evaluator ground truth.

Compare at least four preregistered methods: identity/no intervention; a local smoother or nearest-valid-state projection; an erasure baseline that masks the damaged component or maps it to a neutral state; and a constraint-aware repair that uses the known transition and validity structure but receives no privileged access to the original state.

For every state, execute every action sequence through horizon \(H=3\) or until exhaustive coverage is reached. Report the full metric profile, per-damage severity, together with state-pair confusion tables. Use exact enumeration rather than sampling when the chosen state space permits it.

## Falsifiable predictions

The theory predicts that a genuine repair will improve behavioral and reachability recovery over the damaged input while retaining more distinctions than the smoothing and erasure baselines at matched validity recovery. This prediction fails if smoothing or erasure matches the repair on \(B_R\), \(P_R\), and \(Q_R\) without greater cost or unsupported reconstruction.

As damage merges larger information classes, exact identity recovery must fall, but recovery of behavior common to every member of the class may remain stable. The theory fails its epistemic-boundary claim if a method is credited for identity recovery under non-singleton information classes without additional evidence.

Nearest-valid-state projection is predicted to score well on immediate validity and short-horizon error while losing distinctions that appear under later interventions. This prediction fails if its distinction retention and horizon-dependent behavioral recovery are indistinguishable from the constraint-aware repair.

Erasure is predicted to improve selected aggregate scores only when the evaluation omits unavailable cases or treats a neutral output as success. The diagnosis fails if erasure restores the same action-conditioned behavior and reachability as repair under identical coverage rules.

## Decision rule

Call an operation **repair-like on this benchmark** only if, relative to the damaged input, it increases \(B_R\) and \(Q_R\), does not reduce \(P_R\) beyond a preregistered tolerance, and reports rather than conceals ambiguity through \(U_R\). A method that improves validity while materially reducing \(P_R\) is smoothing. A method that reduces evaluation coverage or removes supported capabilities without restoring them is erasure.

These labels are task- and horizon-relative. Passing the benchmark does not establish repair as a substrate-independent natural kind; it establishes that the proposed quantities discriminate the three operations in a system where the relevant facts are exactly known.

## Minimum outputs

Preserve the state table, transition table, validity predicate, damage maps, information classes, method configurations, exhaustive run results, metric implementation, random seed if any, and one machine-readable summary. The experiment is complete when an independent run reproduces every metric and either separates repair from both controls or records a clear failure of the proposed distinction.
