import express from 'express';

const app = express();

app.use(express.json());
app.use(
  express.urlencoded({
    extended: true,
  }),
);

app.get('/', (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'Digital Family Registration System API is running',
  });
});

export default app;


