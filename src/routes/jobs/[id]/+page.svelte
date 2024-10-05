<script>
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { getProposalsForJob, acceptProposal, releasePayment, getJobs, submitProposal } from '$lib/contract';
  import { formatEther, shortenAddress, parseEther } from '$lib/utils';
  import ProposalCard from '$lib/components/ProposalCard.svelte';
  import Button from '$lib/components/Button.svelte';
  import ProposalForm from '../../../lib/components/ProposalForm.svelte';

  let job;
  let proposals = [];
  let userAddress = '';
  let isEmployer = false;
  let proposalDescription = '';
  let proposalBid = '';

  onMount(async () => {
    const jobId = $page.params.id;
    const allJobs = await getJobs();
    job = allJobs.find(j => j.id.toString() === jobId);
    proposals = await getProposalsForJob(jobId);

    if (typeof window !== 'undefined' && window.ethereum) {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      userAddress = accounts[0];
      isEmployer = job.employer.toLowerCase() === userAddress.toLowerCase();
    }
  });

  async function handleAcceptProposal(proposalId) {
    if (!isEmployer) return;
    await acceptProposal($page.params.id, proposalId);
    proposals = await getProposalsForJob($page.params.id);
  }

  async function handleReleasePayment(proposalId) {
    if (!isEmployer) return;
    await releasePayment($page.params.id, proposalId);
    proposals = await getProposalsForJob($page.params.id);
    job.isOpen = false;
  }

  async function handleSubmitProposal() {
    if (isEmployer || !job.isOpen) return;
    try {
      await submitProposal($page.params.id, proposalDescription, parseEther(proposalBid));
      alert('Proposal submitted successfully!');
      proposalDescription = '';
      proposalBid = '';
      proposals = await getProposalsForJob($page.params.id);
    } catch (error) {
      console.error('Error submitting proposal:', error);
      alert('Failed to submit proposal. Please try again.');
    }
  }
</script>

<svelte:head>
  <title>JobJam - Job Details</title>
</svelte:head>

<div class="max-w-4xl mx-auto">
  <h1 class="text-3xl font-bold mb-6">Job Details</h1>

  {#if job}
    <div class="bg-white shadow-md rounded-lg p-6 mb-6">
      <h2 class="text-2xl font-semibold mb-2">{job.title}</h2>
      <p class="text-gray-600 mb-4">{job.description}</p>
      <span class="text-indigo-600 font-medium">Budget: {formatEther(job.budget)} KLAY(KAIA)</span>
      <p class="mt-2">Status: {job.isOpen ? 'Open' : 'Closed'}</p>
      <p class="mt-2">Employer: {shortenAddress(job.employer)}</p>
    </div>
  {/if}

  {#if !isEmployer && job && job.isOpen}
    <div class="bg-white shadow-md rounded-lg p-6 mb-6">
      <h3 class="text-xl font-semibold mb-4">Submit a Proposal</h3>
      <ProposalForm jobId={$page.params.id} on:proposalSubmitted={handleSubmitProposal} />
    </div>
  {/if}

  <h2 class="text-2xl font-semibold mb-4">Proposals</h2>

  {#if proposals.length === 0}
    <p class="text-gray-600">No proposals submitted yet.</p>
  {:else}
    {#each proposals as proposal (proposal.id)}
      <ProposalCard 
        proposal={proposal} 
        onAccept={handleAcceptProposal} 
        showAcceptButton={isEmployer && job.isOpen} 
      />
    {/each}
  {/if}

  {#if isEmployer && proposals.find(p => p.isAccepted) && job.isOpen}
    <div class="mt-6">
      <Button on:click={() => handleReleasePayment(proposals.find(p => p.isAccepted).id)}>Release Payment</Button>
    </div>
  {/if}
</div>