require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const multer = require('multer');
const FormData = require('form-data');

const app = express();
const PORT = process.env.PORT || 3000;

// Configure multer for file uploads
const upload = multer({ storage: multer.memoryStorage() });

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

const FAL_BASE_URL = 'https://queue.fal.run/fal-ai/nano-banana';
const FAL_EDIT_URL = 'https://queue.fal.run/fal-ai/nano-banana/edit';
const FAL_STORAGE_URL = 'https://fal.run/storage/upload';

// Helper function to get headers
const getHeaders = () => ({
  'Authorization': `Key ${process.env.FAL_API_KEY}`,
  'Content-Type': 'application/json',
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Proxy server is running' });
});

// Submit request to queue (generation)
app.post('/api/nanobana', async (req, res) => {
  try {
    const apiKey = process.env.FAL_API_KEY;
    if (!apiKey) {
      return res.status(500).json({ error: 'API key not configured on server' });
    }

    const response = await axios.post(FAL_BASE_URL, req.body, {
      headers: getHeaders(),
    });

    res.json(response.data);
  } catch (error) {
    console.error('Proxy error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: error.response?.data || 'Internal server error',
    });
  }
});

// Submit request to edit endpoint
app.post('/api/nanobana/edit', async (req, res) => {
  try {
    const apiKey = process.env.FAL_API_KEY;
    if (!apiKey) {
      return res.status(500).json({ error: 'API key not configured on server' });
    }

    console.log('📸 Received edit request:', JSON.stringify(req.body, null, 2));

    const response = await axios.post(FAL_EDIT_URL, req.body, {
      headers: getHeaders(),
    });

    console.log('✅ Edit request submitted successfully');
    console.log('Full response structure:', JSON.stringify(response.data, null, 2));
    res.json(response.data);
  } catch (error) {
    console.error('❌ Edit proxy error:', error.response?.data || error.message);
    console.error('Request body was:', req.body);
    res.status(error.response?.status || 500).json({
      error: error.response?.data || 'Internal server error',
    });
  }
});

// Get request status (generation)
app.get('/api/nanobana/requests/:requestId/status', async (req, res) => {
  try {
    const { requestId } = req.params;
    const response = await axios.get(
      `${FAL_BASE_URL}/requests/${requestId}/status`,
      { headers: getHeaders() }
    );

    res.json(response.data);
  } catch (error) {
    console.error('Status error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: error.response?.data || 'Internal server error',
    });
  }
});

// Get request result (generation)
app.get('/api/nanobana/requests/:requestId', async (req, res) => {
  try {
    const { requestId } = req.params;
    const response = await axios.get(
      `${FAL_BASE_URL}/requests/${requestId}`,
      { headers: getHeaders() }
    );

    res.json(response.data);
  } catch (error) {
    console.error('Result error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: error.response?.data || 'Internal server error',
    });
  }
});

// Get edit request status
app.get('/api/nanobana/edit/requests/:requestId/status', async (req, res) => {
  try {
    const { requestId } = req.params;
    const response = await axios.get(
      `${FAL_EDIT_URL}/requests/${requestId}/status`,
      { headers: getHeaders() }
    );

    console.log(`📊 Status for ${requestId}:`, response.data.status);
    res.json(response.data);
  } catch (error) {
    console.error('Edit status error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: error.response?.data || 'Internal server error',
    });
  }
});

// Get edit request result
app.get('/api/nanobana/edit/requests/:requestId', async (req, res) => {
  try {
    const { requestId } = req.params;
    const response = await axios.get(
      `${FAL_EDIT_URL}/requests/${requestId}`,
      { headers: getHeaders() }
    );

    console.log(`🎉 Result for ${requestId}:`, JSON.stringify(response.data, null, 2));
    res.json(response.data);
  } catch (error) {
    console.error('Edit result error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: error.response?.data || 'Internal server error',
    });
  }
});

// File upload endpoint
app.post('/api/storage/upload', upload.single('file'), async (req, res) => {
  try {
    const apiKey = process.env.FAL_API_KEY;
    if (!apiKey) {
      return res.status(500).json({ error: 'API key not configured on server' });
    }

    if (!req.file) {
      return res.status(400).json({ error: 'No file provided' });
    }

    console.log('📤 Uploading file:', req.file.originalname, `(${(req.file.size / 1024).toFixed(2)} KB)`);

    const formData = new FormData();
    formData.append('file', req.file.buffer, {
      filename: req.file.originalname || 'image.jpg',
      contentType: req.file.mimetype,
    });

    const response = await axios.post(FAL_STORAGE_URL, formData, {
      headers: {
        'Authorization': `Key ${apiKey}`,
        ...formData.getHeaders(),
      },
    });

    console.log('✅ File uploaded successfully:', response.data.url);
    res.json(response.data);
  } catch (error) {
    console.error('❌ Upload error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: error.response?.data || 'Internal server error',
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Proxy server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`API endpoint: http://localhost:${PORT}/api/nanobana`);
  console.log(`Edit endpoint: http://localhost:${PORT}/api/nanobana/edit`);
  console.log(`Upload endpoint: http://localhost:${PORT}/api/storage/upload`);
});
