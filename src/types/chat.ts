export default interface Chat {
  type?: 'system' | 'chat';
  name?: string | null;
  body: string;
  postId: string | null;
  postedAt: string;
}
