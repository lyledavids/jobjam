<script>
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { getProposalsForJob, acceptProposal, releasePayment } from '$lib/contract';
  import { formatEther } from '$lib/utils';
  import ProposalCard from '$lib/components/ProposalCard.svelte';
  import Button from '$lib/components/Button.svelte';
  import ProposalForm from '$lib/components/ProposalForm.svelte';

  let job;
  let proposals = [];

  onMount(async () => {
    const jobId = $page.params.id;
    proposals = await getProposalsForJob(jobId);
  });

  async function handleAcceptProposal(proposalId) {
    await acceptProposal($page.params.id, proposalId);
    proposals = await getProposalsForJob($page.params.id);
  }

  async function handleReleasePayment(proposalId) {
    await releasePayment($page.params.id, proposalId);
    proposals = await getProposalsForJob($page.params.id);
  }

  async function handleProposalSubmitted() {
    proposals = await getProposalsForJob($page.params.id);
  }
</script>

<svelte:head>
  <title>JobJam - Job Details</title>
</svelte:head>

<h1 class="text-3xl font-bold mb-6">Job Details</h1>

{#if job}
  <div class="bg-white shadow-md rounded-lg p-6 mb-6">
    <h2 class="text-2xl font-semibold mb-2">{job.title}</h2>
    <p class="text-gray-600 mb-4">{job.description}</p>
    <span class="text-indigo-600 font-medium">Budget: {formatEther(job.budget)} ETH</span>
  </div>
{/if}

<ProposalForm jobId={$page.params.id} on:proposalSubmitted={handleProposalSubmitted} />

<h2 class="text-2xl font-semibold mb-4">Proposals</h2>

{#each proposals as proposal (proposal.id)}
  <ProposalCard {proposal} onAccept={handleAcceptProposal} />
{/each}

{#if proposals.find(p => p.isAccepted)}
  <Button on:click={() => handleReleasePayment(proposals.find(p => p.isAccepted).id)}>Release Payment</Button>
{/if}