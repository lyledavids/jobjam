<script>
    import { formatEther } from '$lib/utils';
    export let job;
  </script>
  
  <div class="bg-white shadow-md rounded-lg p-6 mb-4">
    <h2 class="text-xl font-semibold mb-2">{job.title}</h2>
    <p class="text-gray-600 mb-4">{job.description}</p>
    <div class="flex justify-between items-center">
      <span class="text-indigo-600 font-medium">Budget: {formatEther(job.budget)} KLAY(KAIA)</span>
      <a href="/jobs/{job.id}" class="bg-indigo-600 text-white px-4 py-2 rounded-md text-sm font-medium">View Details</a>
    </div>
  </div>