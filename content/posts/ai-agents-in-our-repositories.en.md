---
id: ai-agents
slug: ai-agents-in-our-repositories
lang: en
date: 2026-10-14
seoTitle: How AI agents work in our repositories
description: AI agents implement scoped tasks in our code. What checks their work, where a person decides, and what they are never allowed to do.
---

# How AI agents work in our repositories, and what they may not do

We love working with modern technology, and AI is part of that. In our repositories, AI agents implement tasks in
the code. That raises a fair question: who checks what they produce? This post describes how the work is split,
what checks it, where a person decides, and where the limits are.

## One issue, one agent

Every piece of work starts as a GitHub issue: one scoped task, with acceptance criteria and references to the
requirements of the specification it implements. The specification lives in a separate repository, apart from the
code.

An agent takes exactly one issue. It works on its own branch, writes the code and the tests, and opens a pull
request. Smart contracts have their own agent with its own rules; others handle the rest of the code, the copy and
the design.

## A second session reads every pull request

No agent signs off its own work. A separate session reads every pull request against the issue, the specification
and our standards, and sends it back when something is wrong.

Nothing reaches the main branch until a person confirms the merge. No agent can do that alone.

## What checks the work automatically

On top of the review, every repository carries its own checks as scripts, and they run the same way on a
developer's machine and in CI. In our smart-contract repositories they include:

- **Unit and fuzz tests**, offline.
- **Fork tests**, which run against a copy of real chains at a fixed block and call the contracts that are actually
  deployed there, such as price feeds.
- **Static analysis** with Slither and Aderyn, held against a triage record: a new finding without an entry fails
  the check.
- **No borrowed source.** We call protocols such as Safe or Aave through our own interface files. We never copy or
  import their source, not even in tests, because their licences don't fit ours. A check fails on any such import.
- **New state-changing functions** fail a check until someone has decided they belong and listed them.
- **Dependencies** are checked against our licence rules and known vulnerabilities, and each build produces a
  software bill of materials.
- **A secrets scan** searches the files and the history for keys and credentials.
- **A list of forbidden phrases** checks the public texts, for example for promises of a guarantee, or anything that
  suggests a partnership with the providers whose data we read.

## What agents never do

Some things are explicitly off-limits for agents in our repositories, and the commands to deploy and to sign are
blocked in their settings:

- They don't deploy contracts or send a transaction to a real network.
- They don't publish packages or push release tags.
- They don't merge, and they don't close issues.
- They hold no key. No key, secret or keyed RPC URL goes into a repository, a commit message or a log.

There is one exception, and it is narrow. In one repository, agents may send transactions to a local demo chain on
our own machine. They use one of the publicly known test keys, which hold nothing on any real network. Before the first
transaction, a script checks that the target really is that local copy and stops otherwise. The demo chain runs
under its own chain ID, so nothing signed there is valid on the real network.

## Where the limits are

Passing checks don't prove that code is correct. They show that it doesn't have the faults we look for. Agents make
mistakes, and a review doesn't catch every one.

The checks don't block a merge by themselves either. Whoever reviews the pull request reads their results before
merging, and a pull request with no CI run doesn't count as passing.

That is why a person has the last word. A person confirms every merge, and we do every deployment by hand. Before a
release, a separate review agent reads the contracts the way an attacker would and reports what it finds; it fixes
nothing and approves nothing. Where our plan for a project includes an external audit, it happens before the
release.

Once deployed, our contracts can't be changed. A fix is always a new version, so all of this has to happen before.

## Why we're writing this down

If you use our work, support it with a grant or write about it, you should be able to judge how it's made. The rules above live in the
repositories themselves, in the instructions for agents and in `CONTRIBUTING.md`. Once a repository is public, you
can read them there.
