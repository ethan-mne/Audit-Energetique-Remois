import type { APIRoute } from 'astro';

export const post: APIRoute = async ({ request }) => {
  try {
    const payload = await request.text();
    
    // Ici nous retournons simplement une réponse OK
    // Dans un environnement de production, vous devrez implémenter la logique Stripe
    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
};