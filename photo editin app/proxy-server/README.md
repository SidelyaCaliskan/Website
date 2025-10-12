# Spook Edit Proxy Server

This proxy server secures your fal.ai API key by keeping it on the server side instead of embedding it in your Flutter app.

## Setup

### Local Development

1. Install dependencies:
```bash
npm install
```

2. Add your API key to `.env`:
```
FAL_API_KEY=your_actual_api_key_here
```

3. Run the server:
```bash
npm run dev
```

The server will run on `http://localhost:3000`

### Deploy to Vercel (Recommended)

1. Install Vercel CLI:
```bash
npm install -g vercel
```

2. Login to Vercel:
```bash
vercel login
```

3. Deploy:
```bash
vercel
```

4. Add your API key as environment variable:
```bash
vercel env add FAL_API_KEY
```
Enter your API key when prompted.

5. Redeploy to use the new environment variable:
```bash
vercel --prod
```

### Alternative: Deploy to Railway.app

1. Push to GitHub
2. Go to [Railway.app](https://railway.app)
3. Create new project from GitHub repo
4. Add environment variable `FAL_API_KEY` in the dashboard
5. Deploy

## API Endpoints

### Health Check
```
GET /health
```

### Nanobana Image Processing
```
POST /api/nanobana
Content-Type: application/json

{
  "image_url": "https://...",
  "prompt": "your prompt here"
}
```

## Security Notes

- Never commit `.env` file to git
- Use HTTPS in production
- Consider adding rate limiting for production use
- Add authentication if needed
