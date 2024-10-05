<script>
  import { onMount } from 'svelte';
  import { getJobs } from '$lib/contract';
  import JobCard from '$lib/components/JobCard.svelte';

  let jobs = [];

  onMount(async () => {
    jobs = await getJobs();
  });
</script>

<svelte:head>
  <title>JobJam - Home</title>
</svelte:head>

<h1 class="text-3xl font-bold mb-6">Open Jobs</h1>

<div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
  {#each jobs as job (job.id)}
    <JobCard {job} />
  {/each}
</div>