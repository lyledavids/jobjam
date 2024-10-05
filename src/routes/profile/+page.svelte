<script>
    import { onMount } from 'svelte';
    import { getUserProfile ,getJobs } from '$lib/contract';
    import { shortenAddress, formatEther} from '$lib/utils';
  
    let userProfile = [];
    let address = '';
    let allJobs = [];
  
    onMount(async () => {
      if (typeof window !== 'undefined' && window.ethereum) {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        address = accounts[0];
        userProfile = await getUserProfile(address);
        allJobs = await getJobs();
      }
    });
  
    function getJobTitle(jobId) {
        console.log(allJobs)
      const job = allJobs.find(j => j.id.toString() === jobId.toString());
      return job ? job.title : 'Unknown Job';
    }
  
    function getJobStatus(job) {
      if (job.isCompleted) return 'Completed';
      if (!allJobs.find(j => j.id.toString() === job.jobId.toString())?.isOpen) return 'Closed';
      return 'In Progress';
    }
  </script>
  
  <svelte:head>
    <title>JobJam - User Profile</title>
  </svelte:head>
  
  <h1 class="text-3xl font-bold mb-6">User Profile</h1>
  
  <p class="mb-4">Address: {shortenAddress(address)}</p>
  
  <h2 class="text-2xl font-semibold mb-4">Job History</h2>
  
  <div class="grid gap-4">
    {#each userProfile as job (job.jobId)}
      <div class="bg-white shadow-md rounded-lg p-4">
        <p class="font-semibold">{job.title}</p>
        <!-- <p>Job ID: {job.jobId}</p> -->
        <p>Role: {job.isEmployer ? 'Employer' : 'Freelancer'}</p>
        <!-- <p>Budget: {job.budget ? formatEther(job.budget) : 'N/A'} KLAY(KAIA)</p> -->
        <!-- <p>Status: {getJobStatus(job.jobId)}</p> -->
        <div class="flex justify-between items-center">
            <span class="text-indigo-600 font-medium">Budget: {formatEther(job.budget)} KLAY(KAIA)</span>
            <a href="/jobs/{job.id}" class="bg-indigo-600 text-white px-4 py-2 rounded-md text-sm font-medium">View Details</a>
        </div>
      </div>
    {/each}
  </div>